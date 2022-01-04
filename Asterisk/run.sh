#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

if ! bashio::fs.directory_exists '/config/asterisk'; then
    mkdir -p /config/asterisk ||
        bashio::exit.nok 'Failed to create initial asterisk config folder'
fi

bashio::log.info "Configuring certificate..."

certfile="/ssl/$(bashio::config 'certfile')"
keyfile="/ssl/$(bashio::config 'keyfile')"
readonly certfile keyfile

if ! bashio::fs.file_exists "${certfile}"; then
    bashio::exit.nok "Certificate file at ${certfile} was not found"
fi

if ! bashio::fs.file_exists "${keyfile}"; then
    bashio::exit.nok "Key file at ${keyfile} was not found"
fi

cat "${certfile}" <(echo) "${keyfile}" > /etc/asterisk/keys/asterisk.pem

cp -a -f /etc/asterisk/keys/. /config/asterisk/keys/ || bashio::exit.nok 'Failed to update certificate'

bashio::log.info "Configuring Asterisk..."

bashio::var.json \
    password "$(bashio::config 'ami_password')" \
    ip "$(getent hosts homeassistant | awk '{ print $1 }')" |
    tempio \
        -template /usr/share/tempio/manager.conf.gtpl \
        -out /etc/asterisk/manager.conf

bashio::var.json \
    certificate "$(bashio::config 'certificate')" \
    key "$(bashio::config 'key')" |
    tempio \
    -template /usr/share/tempio/http.conf.gtpl \
    -out /etc/asterisk/http.conf

tempio \
    -template /usr/share/tempio/rtp.conf.gtpl \
    -out /etc/asterisk/rtp.conf

sed -i 's/noload => chan_sip.so/;noload => chan_sip.so/' /etc/asterisk/modules.conf >/dev/null

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