ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:11.0.1
FROM $BUILD_FROM

# Install Asterisk and Python3
ARG ASTERISK_VERSION=18.2.2-r5
RUN apk add --update --no-cache \
    asterisk="${ASTERISK_VERSION}" \
    asterisk-srtp="${ASTERISK_VERSION}" \
    asterisk-sample-config="${ASTERISK_VERSION}" \
    asterisk-sounds-en="${ASTERISK_VERSION}" \
    asterisk-sounds-moh="${ASTERISK_VERSION}" \
    asterisk-speex="${ASTERISK_VERSION}" \
    asterisk-dahdi="${ASTERISK_VERSION}" \
    rsync=~3.2.3-r5 \
    python3

# Python3 dependencies
RUN python3 -m ensurepip

RUN pip3 install asterisk_mbox_server --no-cache-dir

COPY rootfs /