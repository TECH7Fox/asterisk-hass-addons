#!/usr/bin/env bash


readonly JSON_CONFIG_FILE="/data/options.json"

# Load configuration values using either `bashio::config` (if supervisor is available) or from a JSON file
function config() {
    local key=${1}
    
    # Try to read the configuration from the supervisor API.
    # If the supervisor is not available (the function returns an empty JSON), fallback to the `/data/options.json` file, and extract each option using jq
    json_config=$(bashio::addon.config)

    if [[ "${json_config}" = "{}" ]]; then
    
        bashio::log.info "Loading configuration from $JSON_CONFIG_FILE"
        json_config=$(cat $JSON_CONFIG_FILE)
    fi
    
    # `bashio::config` try to load the given config key from the supervisor, otherwise it fallbacks to the value of the second parameter
    bashio::config "${key}" "$(bashio::jq "${json_config}" ."${key}")"
}