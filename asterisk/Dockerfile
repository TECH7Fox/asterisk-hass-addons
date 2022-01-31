ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:11.0.1
FROM $BUILD_FROM

# Install Asterisk
RUN apk add --update --no-cache \
    asterisk \
    asterisk-srtp \
    asterisk-sample-config \
    asterisk-sounds-en \
    asterisk-sounds-moh \
    asterisk-speex \
    asterisk-dahdi \
    rsync

COPY rootfs /
