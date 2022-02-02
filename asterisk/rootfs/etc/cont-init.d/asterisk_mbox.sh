#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures Asterisk mailbox server
# ==============================================================================

# shellcheck shell=bash

bashio::var.json \
    port "$(bashio::config 'mailbox_port')" \
    password "$(bashio::config 'mailbox_password')" \
    extension "$(bashio::config 'mailbox_extension')" \
    api_key "$(bashio::config 'mailbox_google_api_key')" |
    tempio \
    -template /usr/share/tempio/asterisk_mbox.ini.gtpl \
    -out /config/asterisk/asterisk_mbox.ini