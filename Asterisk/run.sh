#!/usr/bin/with-contenv bashio

bashio::log.info "Checking config files..."

if ! bashio::fs.directory_exists '/config/asterisk'; then
    mkdir -p /config/asterisk \
        || bashio::exit.nok 'Failed to create initial asterisk config folder'
fi

AMI_PASSWORD=$(bashio::config 'ami_password')
HA_IP=$(getent hosts homeassistant | awk '{ print $1 }')

cat <<'EOF' > '/etc/asterisk/manager.conf'
[general]
enabled = yes
port = 5038
bindaddr = 0.0.0.0
displayconnects = yes

[admin]
secret = %%AMI_PASSWORD%%
deny = 0.0.0.0/0.0.0.0
permit = %%HA_IP%%/255.255.255.254
read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
writetimeout = 5000
EOF

sed -i "s/%%AMI_PASSWORD%%/$AMI_PASSWORD/g" '/etc/asterisk/manager.conf'
sed -i "s/%%HA_IP%%/$HA_IP/g" '/etc/asterisk/manager.conf'

echo '
[general]
enabled=yes
bindaddr=0.0.0.0
bindport=8088
tlsenable=yes
tlsbindaddr=0.0.0.0:8089
tlscertfile=/etc/asterisk/keys/asterisk.pem
tlsprivatekey=/etc/asterisk/keys/asterisk.pem
' > '/etc/asterisk/http.conf'

echo '
[general]
rtpstart=10000
rtpend=10008
' > '/etc/asterisk/rtp.conf'

echo $'
[general]
udpbindaddr=0.0.0.0
bind=0.0.0.0
bindaddr=0.0.0.0
protocol=udp

[sipjs-phone](!)
type=friend
host=dynamic ; Allows any host to register
encryption=yes ; Tell Asterisk to use encryption for this peer
avpf=yes ; Tell Asterisk to use AVPF for this peer
icesupport=yes ; Tell Asterisk to use ICE for this peer
context=default ; Tell Asterisk which context to use when this peer is dialing
directmedia=no ; Asterisk will relay media for this peer
transport=wss,udp,tls ; Asterisk will allow this peer to register on UDP or WebSockets
force_avp=yes ; Force Asterisk to use avp. Introduced in Asterisk 11.11
dtlsenable=yes ; Tell Asterisk to enable DTLS for this peer
dtlsverify=fingerprint ; Tell Asterisk to verify DTLS fingerprint
dtlscertfile=/etc/asterisk/keys/asterisk.pem ; Tell Asterisk where your DTLS cert file is
dtlssetup=actpass ; Tell Asterisk to use actpass SDP parameter when setting up DTLS
rtcp_mux=yes ; Tell Asterisk to do RTCP mux
dtmfmode=rfc2833
\n
[my-codecs](!)
allow=!all,ulaw,alaw,speex,gsm,g726,g723\n
\n
' > '/etc/asterisk/sip.conf'

sed -i 's/noload => chan_sip.so/;noload => chan_sip.so/' /etc/asterisk/modules.conf > /dev/null

if ! bashio::fs.file_exists '/config/asterisk/sip.conf'; then
    cp -a /etc/asterisk/. /config/asterisk/ \
        || bashio::exit.nok 'Failed to make sample configs'
fi

bashio::log.info "Creating certificate..."

# REPLACE WITH CERTBOT
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=NL/ST=Denial/L=Amsterdam/O=Dis/CN=Asterisk" \
    -keyout /etc/asterisk/keys/asterisk.key  -out /etc/asterisk/keys/asterisk.cert > /dev/null

cat /etc/asterisk/keys/asterisk.key > /etc/asterisk/keys/asterisk.pem
cat /etc/asterisk/keys/asterisk.cert >> /etc/asterisk/keys/asterisk.pem

cp -a -f  /etc/asterisk/keys/. /config/asterisk/keys/ || bashio::exit.nok 'Failed to update certificate'

bashio::log.info "Configuring Asterisk..."

cp -a -f /config/asterisk/. /etc/asterisk/ || bashio::exit.nok 'Failed to get config from /config/asterisk folder'

PERSONS=$(curl -s -X GET -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" http://supervisor/core/api/states | jq -r '.[] | select(.entity_id | contains("person.")).attributes.id')
AUTO_ADD=$(bashio::config 'auto_add')

if $AUTO_ADD; then
    EXTENSION=100
    for person in ${PERSONS}
    do
    EXTENSION=$((${EXTENSION}+1))
    echo "
[${EXTENSION}](sipjs-phone,my-codecs)
username=${EXTENSION}
secret=1234
    " >> '/etc/asterisk/sip.conf'
    done
fi

bashio::log.info "Starting Asterisk..."

exec asterisk -vvvvvvvvv -ddddddddddd -f

# RUN ANOTHER SCRIPT UPDATING THE ENTITIES AND KEEP ASTERISK CONSOLE HERE

# sleep 10

# while true
# do
#     echo " "
#     bashio::log.info $(asterisk -x "sip show peers")
#     sleep 5
#     echo " "
#     bashio::log.info $(asterisk -x "http show status")
#     sleep 5
#     echo " "
#     if $AUTO_ADD; then
#         EXTENSION=100
#         for person in ${PERSONS}
#         do
#             EXTENSION=$((${EXTENSION}+1))
#             if asterisk -x "sip show peers" | grep "${EXTENSION}" | grep '(Unspecified)' > /dev/null; then
#                 STATE='off'
#             else
#                 STATE='on'
#             fi
#             curl -s -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" -d '{"state": "'"${STATE}"'", "attributes": {"extension": "'"${EXTENSION}"'", "secret": "1234", "user": "'"${person}"'"}}' "http://supervisor/core/api/states/binary_sensor.sip_${person}" > /dev/null
#         done
#     fi

#     for extension in $(bashio::config 'custom_extensions|keys')
#     do
#         EXTENSION=$(bashio::config "custom_extensions[${extension}].extension")
#         NAME=$(bashio::config "custom_extensions[${extension}].name")
#         TYPE=$(bashio::config "custom_extensions[${extension}].type")
#         if [ $TYPE = "chan_sip" ]; then
#             if asterisk -x "sip show peers" | grep "${EXTENSION}" | grep '(Unspecified)' > /dev/null; then
#                 STATE='off'
#             else
#                 STATE='on'
#             fi
#         else
#             if asterisk -x "pjsip show endpoints" | grep "${EXTENSION}" | grep '(Unspecified)' > /dev/null; then
#                 STATE='off'
#             else
#                 STATE='on'
#             fi
#         fi
#         curl -s -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H "Content-Type: application/json" -d '{"state": "'"${STATE}"'", "attributes": {"extension": "'"${EXTENSION}"'", "user": "'"${NAME}"'"}}' "http://supervisor/core/api/states/binary_sensor.sip_${NAME}" > /dev/null
#     done
# done