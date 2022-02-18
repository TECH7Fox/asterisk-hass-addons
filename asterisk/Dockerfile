ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/hassio-addons/base-python/${BUILD_ARCH}:8.0.1


FROM $BUILD_FROM

ARG BUILD_ARCH

# Reinstall S6 Overlay as a fix to https://github.com/hassio-addons/addon-base-python/issues/102
# This should be removed once a fix for it is released.
# Taken from: https://github.com/hassio-addons/addon-base/blob/8343e5cabb52ad392b5166c9dcc8abb802afe101/base/Dockerfile#L40-L45
# hadolint ignore=DL4006
RUN S6_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "i386" ]; then S6_ARCH="x86"; fi \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then S6_ARCH="arm"; fi \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-${S6_ARCH}.tar.gz" \
        | tar zxvf - -C /

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