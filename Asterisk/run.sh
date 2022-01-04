#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

bashio::log.info "Checking config files..."

if ! bashio::fs.directory_exists '/config/asterisk'; then
    mkdir -p /config/asterisk ||
        bashio::exit.nok 'Failed to create initial asterisk config folder'
fi

AMI_PASSWORD=$(bashio::config 'ami_password')
HA_IP=$(getent hosts homeassistant | awk '{ print $1 }')

cat <<'EOF' >'/etc/asterisk/manager.conf'
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
' >'/etc/asterisk/http.conf'

echo '
[general]
rtpstart=10000
rtpend=10008
' >'/etc/asterisk/rtp.conf'

sed -i 's/noload => chan_sip.so/;noload => chan_sip.so/' /etc/asterisk/modules.conf >/dev/null

bashio::log.info "Creating certificate..."

# REPLACE WITH CERTBOT
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=NL/ST=Denial/L=Amsterdam/O=Dis/CN=Asterisk" \
    -keyout /etc/asterisk/keys/asterisk.key -out /etc/asterisk/keys/asterisk.cert >/dev/null

cat /etc/asterisk/keys/asterisk.key >/etc/asterisk/keys/asterisk.pem
cat /etc/asterisk/keys/asterisk.cert >>/etc/asterisk/keys/asterisk.pem

cp -a -f /etc/asterisk/keys/. /config/asterisk/keys/ || bashio::exit.nok 'Failed to update certificate'

bashio::log.info "Configuring Asterisk..."

# Generate sip.conf configuration
persons="$(curl -s -X GET \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    http://supervisor/core/api/states |
    jq -c '[.[] | select(.entity_id | contains("person.")).attributes.id]')"

bashio::var.json \
    auto_add "^$(bashio::config 'auto_add')" \
    persons "^${persons}" |
    tempio \
        -template /usr/share/tempio/sip.conf.gtpl \
        -out /etc/asterisk/sip.conf

if ! bashio::fs.file_exists '/config/asterisk/sip.conf'; then
    cp -a /etc/asterisk/. /config/asterisk/ ||
        bashio::exit.nok 'Failed to make sample configs'
fi

cp -a -f /config/asterisk/. /etc/asterisk/ || bashio::exit.nok 'Failed to get config from /config/asterisk folder'

bashio::log.info "Starting Asterisk..."

exec asterisk -U asterisk -vvvdddf