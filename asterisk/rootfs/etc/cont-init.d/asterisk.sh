#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures Asterisk
# ==============================================================================

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

readonly target_certfile="/etc/asterisk/keys/fullchain.pem"
readonly target_keyfile="/etc/asterisk/keys/privkey.pem"

mkdir -p /etc/asterisk/keys

cp -f "${certfile}" "${target_certfile}"
cp -f "${keyfile}" "${target_keyfile}"
cat "${target_keyfile}" <(echo) "${target_certfile}" > /etc/asterisk/keys/asterisk.pem
chown asterisk: /etc/asterisk/keys/*.pem
chmod 600 /etc/asterisk/keys/*.pem

cp -a -f /etc/asterisk/keys/. /config/asterisk/keys/ || bashio::exit.nok 'Failed to update certificate'

bashio::log.info "Configuring Asterisk..."

# Files that can't be changed by user go to /config/asterisk to prevent being overwritten.

bashio::var.json \
    password "$(bashio::config 'ami_password')" |
    tempio \
        -template /usr/share/tempio/manager.conf.gtpl \
        -out /config/asterisk/manager.conf

bashio::var.json \
    certfile "${target_certfile}" \
    keyfile "${target_keyfile}" |
    tempio \
    -template /usr/share/tempio/http.conf.gtpl \
    -out /config/asterisk/http.conf

persons="$(curl -s -X GET \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    http://supervisor/core/api/states |
    jq -c '[.[] | select(.entity_id | contains("person.")).attributes.id]')"

if bashio::config 'video_support'; then
    video_support = "yes"
else
    video_support = "no"
fi

bashio::var.json \
    auto_add "^$(bashio::config 'auto_add')" \
    video_support video_support \
    persons "^${persons}" |
    tempio \
        -template /usr/share/tempio/sip_default.conf.gtpl \
        -out /config/asterisk/sip_default.conf

rsync -a -v --ignore-existing /etc/asterisk/. /config/asterisk/ || bashio::exit.nok 'Failed to make sample configs.' # Doesn't overwrite
cp -a -f /config/asterisk/. /etc/asterisk/ || bashio::exit.nok 'Failed to get config from /config/asterisk.' # Does overwrite
