ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:edge
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
    rsync \
    python3 \
    py3-pip

RUN pip3 install asterisk_mbox_server --no-cache-dir

COPY rootfs /