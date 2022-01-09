#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures NGINX
# ==============================================================================

# shellcheck shell=bash

bashio::log.info "Configuring NGINX..."

# Get assigned Ingress port
ingress_port=$(bashio::addon.ingress_port)
readonly ingress_port

bashio::var.json \
    ingress_port "^${ingress_port}" |
    tempio \
    -template /usr/share/tempio/ingress.conf.gtpl \
    -out /etc/nginx/http.d/ingress.conf