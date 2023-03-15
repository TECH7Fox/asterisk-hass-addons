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

readonly target_certfile="/etc/asterisk/keys/fullchain.pem"
readonly target_keyfile="/etc/asterisk/keys/privkey.pem"

mkdir -p /etc/asterisk/keys

if bashio::var.true "$(bashio::config 'generate_ssl_cert')"; then
    bashio::log.info "Generating a self-signed certificate..."
    
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=NL/ST=Denial/L=Amsterdam/O=Dis/CN=Asterisk" \
        -keyout "${target_keyfile}" -out "${target_certfile}" >/dev/null
else
    bashio::log.info "Using existing certificate as 'generate_ssl_certificate' is disabled..."

    if ! bashio::fs.file_exists "${certfile}"; then
        bashio::exit.nok "Certificate file at ${certfile} was not found"
    fi

    if ! bashio::fs.file_exists "${keyfile}"; then
        bashio::exit.nok "Key file at ${keyfile} was not found"
    fi

    cp -f "${certfile}" "${target_certfile}"
    cp -f "${keyfile}" "${target_keyfile}"
fi

cat "${target_keyfile}" <(echo) "${target_certfile}" > /etc/asterisk/keys/asterisk.pem
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
    log_level "$(bashio::config 'log_level')" |
    tempio \
        -template /usr/share/tempio/logger.conf.gtpl \
        -out /config/asterisk/logger.conf

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

auto_add=$(bashio::config 'auto_add')
auto_add_secret=$(bashio::config 'auto_add_secret')
video_support=$(bashio::config 'video_support')
if bashio::var.true "${auto_add}" && bashio::var.is_empty "${auto_add_secret}"; then
    bashio::exit.nok "'auto_add_secret' must be set when 'auto_add' is enabled"
fi

bashio::var.json \
    auto_add "^${auto_add}" \
    auto_add_secret "${auto_add_secret}" \
    video_support "^${video_support}" \
    persons "^${persons}" |
    tempio \
        -template /usr/share/tempio/pjsip_default.conf.gtpl \
        -out /config/asterisk/pjsip_default.conf
        
 bashio::var.json \
    auto_add "^${auto_add}" \
    auto_add_secret "${auto_add_secret}" \
    video_support "^${video_support}" \
    persons "^${persons}" |
    tempio \
        -template /usr/share/tempio/sip_default.conf.gtpl \
        -out /config/asterisk/sip_default.conf    

rsync -a -v --ignore-existing /etc/asterisk/. /config/asterisk/ || bashio::exit.nok 'Failed to make sample configs.' # Doesn't overwrite
cp -a -f /config/asterisk/. /etc/asterisk/ || bashio::exit.nok 'Failed to get config from /config/asterisk.' # Does overwrite
