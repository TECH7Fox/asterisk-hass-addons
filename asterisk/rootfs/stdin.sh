#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

function is_addon() {
    [[ -n "${SUPERVISOR_TOKEN:-}" ]]
}

if ! is_addon; then
    exec sleep infinity
fi

bashio::log.info 'Starting the STDIN service for Home Assistant...'

# shellcheck disable=SC2162
while read -r input; do
    # Parse JSON value
    input=$(bashio::jq "${input}" '.')

    bashio::log.info "Executing command from stdin: asterisk -rx '${input}'"
    # Ignore failures, otherwise the add-on would be restarted
    asterisk -rx "${input}" || true
done
