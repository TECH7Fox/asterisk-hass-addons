#!/usr/bin/with-contenv bashio
# ==============================================================================
# Register ingress_url in HA
# ==============================================================================

# shellcheck shell=bash

function api_call {
  curl -sS -H "Authorization: Bearer $SUPERVISOR_TOKEN" -H "content-type: application/json" "$@"
}

if [[ -n "${SUPERVISOR_TOKEN:-}" ]]; then
    INGRESS_ENTRY=$(api_call -X GET http://supervisor/addons/self/info | jq -r .data.ingress_entry)
    bashio::log.info ingress_entry: $INGRESS_ENTRY
    api_call -X POST http://supervisor/core/api/states/text.asterisk_addon_ingress_entry -d '{"state": "'${INGRESS_ENTRY}'"}'
fi
