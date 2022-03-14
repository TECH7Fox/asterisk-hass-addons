ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/${BUILD_ARCH}:5.3.0


FROM $BUILD_FROM AS base

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
        gcc \
        g++ \
        libc6-dev \
        python3-dev \
        libbinutils \
        file \
        ca-certificates \
        curl \
        libcurl4 \
        libedit2 \
        libgsm1 \
        libogg0 \
        libopus0 \
        libopusfile0 \
        libpopt0 \
        libresample1 \
        libspandsp2 \
        libspeex1 \
        libspeexdsp1 \
        libsqlite3-0 \
        libsrtp2-1 \
        libssl1.1 \
        libvorbis0a \
        libxml2 \
        libxslt1.1 \
        libncurses5 ncurses-bin ncurses-term \
        procps \
        python3-pip \
        python-setuptools \
        rsync \
        sipgrep \
        tcpdump \
        uuid \
        xmlstarlet; \
    \
    pip3 install --no-cache-dir asterisk_mbox_server==0.5.3; \
    \
    groupadd --system  asterisk; \
    useradd --system --gid asterisk --home-dir /var/lib/asterisk asterisk; \
    \
    apt-get purge -y --auto-remove gcc g++ libc6-dev python3-dev; \
    \
    rm -rf /var/lib/apt/lists/*

ENV ASTERISK_VERSION="18.10.1"


FROM base AS build

COPY build-asterisk.sh /

RUN /build-asterisk.sh


FROM scratch AS rootfs

COPY --from=build /opt/asterisk/ /

COPY rootfs /


FROM base

COPY --from=rootfs / /
