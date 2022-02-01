ARG BUILD_FROM=ghcr.io/hassio-addons/base-python/amd64:8.0.1
FROM $BUILD_FROM

# Install Asterisk
ARG ASTERISK_VERSION=18.2.2-r5
RUN apk add --update --no-cache \
    asterisk="${ASTERISK_VERSION}" \
    asterisk-srtp="${ASTERISK_VERSION}" \
    asterisk-sample-config="${ASTERISK_VERSION}" \
    asterisk-sounds-en="${ASTERISK_VERSION}" \
    asterisk-sounds-moh="${ASTERISK_VERSION}" \
    asterisk-speex="${ASTERISK_VERSION}" \
    asterisk-dahdi="${ASTERISK_VERSION}" \
    rsync=~3.2.3-r5

# Install mailbox server
RUN apk add --no-cache --virtual .build-dependencies build-base \
    && pip3 install --no-cache-dir asterisk_mbox_server==0.5.3 \
    && apk del --purge .build-dependencies

COPY rootfs /