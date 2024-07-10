#!/usr/bin/with-contenv bashio
# ==============================================================================
# Run custom startup if exists
# ==============================================================================

# shellcheck shell=bash

readonly custom_startup="/config/asterisk/startup.sh"
if [[ -f "${custom_startup}" ]]; then
    bashio::log.info "Running custom startup script..."
    bashio::log.debug "Executing ${custom_startup}"
    source "${custom_startup}"
fi
