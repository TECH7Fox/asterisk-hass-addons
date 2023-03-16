#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures Asterisk mailbox server
# ==============================================================================

# shellcheck shell=bash

# See comments in `asterish.sh` for reference
json_config=$(bashio::addon.config)
if [[ "${json_config}" = "{}" ]]; then
    json_config_file="/data/options.json"
    
    bashio::log.info "Loading configuration from $json_config_file"
    json_config=$(cat $json_config_file)
fi

bashio::var.json \
    port "$(bashio::config 'mailbox_port' "$(bashio::jq "${json_config}" .mailbox_port)")" \
    password "$(bashio::config 'mailbox_password' "$(bashio::jq "${json_config}" .mailbox_password)")" \
    extension "$(bashio::config 'mailbox_extension' "$(bashio::jq "${json_config}" .mailbox_extension)")" \
    api_key "$(bashio::config 'mailbox_google_api_key' "$(bashio::jq "${json_config}" .mailbox_google_api_key)")" |
    tempio \
    -template /usr/share/tempio/asterisk_mbox.ini.gtpl \
    -out /config/asterisk/asterisk_mbox.ini
