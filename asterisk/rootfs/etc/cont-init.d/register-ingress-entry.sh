#!/usr/bin/with-contenv bashio
# ==============================================================================
# Register ingress_url in HA
# ==============================================================================

# shellcheck shell=bash

if [[ -z "${SUPERVISOR_TOKEN:-}" ]]; then
    exit 0
fi

if bashio::config.true 'register_ingress_entry'; then
    ingress_entry=$(
        curl -fsSL -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/addons/self/info |
            jq -er .data.ingress_entry
    )
    bashio::log.debug "ingress_entry: ${ingress_entry}"
    curl -fsSL -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        -X POST http://supervisor/core/api/states/text.asterisk_addon_ingress_entry \
        -d '{"state": "'"${ingress_entry}"'"}'
fi
