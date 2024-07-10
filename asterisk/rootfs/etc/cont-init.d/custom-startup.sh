#!/usr/bin/with-contenv bashio
# ==============================================================================
# Run custom startup if exists
# ==============================================================================

# shellcheck shell=bash

readonly custom_startup="/config/asterisk/startup.sh"
if bashio::fs.file_exists "${custom_startup}"; then
    bashio::log.info "Running custom startup script..."
    source "${custom_startup}" || bashio::log.error "Failed executing ${custom_startup}"
fi
