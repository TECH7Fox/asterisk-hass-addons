#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures Asterisk mailbox server
# ==============================================================================

# shellcheck shell=bash

# Load helper function
# shellcheck source=/dev/null
source /usr/lib/config.sh

bashio::var.json \
    port "$(config 'mailbox_port')" \
    password "$(config 'mailbox_password')" \
    extension "$(config 'mailbox_extension')" \
    api_key "$(config 'mailbox_google_api_key')" |
    tempio \
    -template /usr/share/tempio/asterisk_mbox.ini.gtpl \
    -out /config/asterisk/asterisk_mbox.ini
