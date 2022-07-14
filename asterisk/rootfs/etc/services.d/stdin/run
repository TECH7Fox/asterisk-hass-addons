#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Asterisk
# Starts the STDIN service
# ==============================================================================

# shellcheck shell=bash

bashio::log.info 'Starting the Home Assistant STDIN service...'

# shellcheck disable=SC2162
while read cmd; do
  cmd="${cmd%\"}"
  cmd="${cmd#\"}"

  bashio::log.info "Received external command: ${cmd}"

  case "${cmd}" in

        "reload_pjsip")
            bashio::log.info "Reloading PJSIP..."
            cp /config/asterisk/pjsip_custom.conf /etc/asterisk/pjsip_custom.conf
            cp /config/asterisk/pjsip.conf /etc/asterisk/pjsip.conf
            asterisk -x module reload res_pjsip
        ;;

        "reload_dialplan")
            bashio::log.info "Reloading dialplan..."
            cp /config/asterisk/extensions.conf /etc/asterisk/extensions.conf
            asterisk -x dialplan reload
        ;;

        *)
            bashio::log.warning "Unknown STDIN command: ${cmd}"
        ;;

    esac

done < /proc/1/fd/0