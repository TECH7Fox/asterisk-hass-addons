#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures the timezone, at least until the following PR does not get released
# https://github.com/hassio-addons/addon-debian-base/pull/108
# ==============================================================================

if ! bashio::var.is_empty "${TZ}"; then
    bashio::log.info "Configuring timezone"

    ln --symbolic --no-dereference --force "/usr/share/zoneinfo/${TZ}" /etc/localtime
    echo "${TZ}" > /etc/timezone
fi
