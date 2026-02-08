#!/bin/bash

function is_addon() {
    [[ -n "${SUPERVISOR_TOKEN:-}" ]]
}

# Stub scripts that only works as an add-on
if ! is_addon; then
    cp -f /etc/asterisk-addon/noop.sh /package/admin/s6-overlay/etc/s6-rc/scripts/base-app-log-level
    cp -f /etc/asterisk-addon/noop.sh /package/admin/s6-overlay/etc/s6-rc/scripts/base-app-banner
fi

exec /init "${@}"
