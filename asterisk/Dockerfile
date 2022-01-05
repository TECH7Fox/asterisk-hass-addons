ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:edge
FROM $BUILD_FROM

# Install Asterisk
RUN apk add --update --no-cache \
    asterisk \
    asterisk-srtp \
    asterisk-sample-config \
    asterisk-sounds-en \
    asterisk-speex \
    asterisk-dahdi \
    rsync

COPY rootfs /
