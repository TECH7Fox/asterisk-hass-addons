#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures Asterisk
# ==============================================================================

# shellcheck shell=bash

readonly etc_asterisk="/etc/asterisk"
readonly config_dir="/config/asterisk"
readonly default_config_dir="${config_dir}/default"
readonly custom_config_dir="${config_dir}/custom"

readonly tempio_dir="/usr/share/tempio"

# Ensure the config folders exist
if ! mkdir -p "${default_config_dir}" "${custom_config_dir}"; then
    bashio::exit.nok "Failed to create Asterisk config folders at ${config_dir}"
fi

bashio::log.info "Configuring certificate..."

certfile="/ssl/$(bashio::config 'certfile')"
keyfile="/ssl/$(bashio::config 'keyfile')"
readonly certfile keyfile

readonly keys_dir="${etc_asterisk}/keys"
readonly target_certfile="${keys_dir}/fullchain.pem"
readonly target_keyfile="${keys_dir}/privkey.pem"

mkdir -p "${keys_dir}"

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

cat "${target_keyfile}" <(echo) "${target_certfile}" >${keys_dir}/asterisk.pem
chmod 600 "${keys_dir}"/*.pem

bashio::log.info "Generating Asterisk config files from add-on configuration..."

bashio::var.json \
    password "$(bashio::config 'ami_password')" |
    tempio \
        -template "${tempio_dir}/manager.conf.gtpl" \
        -out "${etc_asterisk}/manager.conf"

bashio::var.json \
    log_level "$(bashio::config 'log_level')" |
    tempio \
        -template "${tempio_dir}/logger.conf.gtpl" \
        -out "${etc_asterisk}/logger.conf"

bashio::var.json \
    certfile "${target_certfile}" \
    keyfile "${target_keyfile}" |
    tempio \
        -template "${tempio_dir}/http.conf.gtpl" \
        -out "${etc_asterisk}/http.conf"

persons="$(
    curl -fsSL -X GET \
        -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        -H "Content-Type: application/json" \
        http://supervisor/core/api/states |
        jq -c '[.[] | select(.entity_id | contains("person.")).attributes.id]'
)"

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
        -template "${tempio_dir}/pjsip_default.conf.gtpl" \
        -out "${etc_asterisk}/pjsip_default.conf"

bashio::var.json \
    auto_add "^${auto_add}" \
    auto_add_secret "${auto_add_secret}" \
    video_support "^${video_support}" \
    persons "^${persons}" |
    tempio \
        -template "${tempio_dir}/sip_default.conf.gtpl" \
        -out "${etc_asterisk}/sip_default.conf"

bashio::var.json \
    port "$(bashio::config 'mailbox_port')" \
    password "$(bashio::config 'mailbox_password')" \
    extension "$(bashio::config 'mailbox_extension')" \
    api_key "$(bashio::config 'mailbox_google_api_key')" |
    tempio \
        -template "${tempio_dir}/asterisk_mbox.ini.gtpl" \
        -out "${etc_asterisk}/asterisk_mbox.ini"

# Save default configs
bashio::log.info "Saving default configs to ${default_config_dir}..."
if ! rsync --archive --delete "${etc_asterisk}/" "${default_config_dir}/"; then
    bashio::exit.nok "Failed to copy default configs to ${default_config_dir}"
fi

# Restore custom configs
bashio::log.info "Restoring custom configs from ${custom_config_dir}..."
for file in "${custom_config_dir}"/*; do
    rel_file="$(basename "${file}")"
    ln -svf "${custom_config_dir}/${rel_file}" "${etc_asterisk}/${rel_file}"
done
