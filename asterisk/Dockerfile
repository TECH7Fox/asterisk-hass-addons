ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/hassio-addons/base-python/${BUILD_ARCH}:8.1.0


FROM $BUILD_FROM

ARG BUILD_ARCH

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
    rsync=~3.2.3-r5 \
    openssl=~1.1.1l-r8

# Install mailbox server
RUN apk add --no-cache --virtual .build-dependencies build-base=0.5-r2 \
    && pip3 install --no-cache-dir asterisk_mbox_server==0.5.3 \
    && apk del --purge .build-dependencies

COPY rootfs /