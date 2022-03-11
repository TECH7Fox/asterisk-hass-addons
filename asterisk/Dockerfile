ARG BUILD_ARCH=amd64

ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/${BUILD_ARCH}:5.3.0

FROM $BUILD_FROM

ARG BUILD_ARCH

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            autoconf \
            file \
            binutils-dev \
            build-essential \
            ca-certificates \
            curl \
            less \
            libcurl4-openssl-dev \
            libedit-dev \
            libgsm1-dev \
            libogg-dev \
            libpopt-dev \
            libresample1-dev \
            libspandsp-dev \
            libspeex-dev \
            libspeexdsp-dev \
            libsqlite3-dev \
            libsrtp2-dev \
            libssl-dev \
            libvorbis-dev \
            libxml2-dev \
            libxslt1-dev \
            libncurses5 ncurses-bin ncurses-term \
            portaudio19-dev \
            procps \
            python3-pip \
            python-setuptools \
            rsync \
            sipgrep \
            tcpdump \
            unixodbc-dev \
            uuid \
            uuid-dev \
            xmlstarlet \
	    && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

RUN useradd --system asterisk
RUN pip3 install asterisk_mbox_server==0.5.3

ENV ASTERISK_VERSION=18.10.1

COPY build-asterisk.sh /build-asterisk

RUN /build-asterisk && rm -f /build-asterisk

COPY rootfs /
