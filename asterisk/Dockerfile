ARG BUILD_ARCH=amd64
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/${BUILD_ARCH}:5.3.0

FROM $BUILD_FROM AS build

ENV ASTERISK_VERSION=18.10.1

COPY build-asterisk.sh /build-asterisk

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends --no-install-suggests \
            autoconf \
            file \
            binutils-dev \
            build-essential \
            ca-certificates \
            curl \
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
            unixodbc-dev \
            uuid \
            uuid-dev \
            xmlstarlet \
	    && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/* && \
    useradd --system asterisk && \
    chmod +x /build-asterisk && \
    /build-asterisk && rm -f /build-asterisk

FROM scratch AS rootfs

COPY rootfs /

FROM ${BUILD_FROM}

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends --no-install-suggests \
            libbinutils \
            file \
            ca-certificates \
            curl \
            libcurl4 \
            libedit2 \
            libgsm1 \
            libogg0 \
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
            libportaudio2 \
            procps \
            python3-pip \
            python-setuptools \
            rsync \
            sipgrep \
            tcpdump \
            unixodbc \
            uuid \
            xmlstarlet \
	    && \
    pip3 install --no-cache-dir asterisk_mbox_server==0.5.3 && \
    apt-get purge -y --auto-remove \
            perl \
            perl-modules \
            perl-modules-* \
        && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/sbin/ast* /usr/sbin/autosupport /usr/sbin/rasterisk /usr/sbin/safe_asterisk /usr/sbin/
COPY --from=build /lib/libasterisk* /lib/
COPY --from=build /usr/lib/asterisk/ /usr/lib/asterisk/
COPY --from=build /var/lib/asterisk/ /var/lib/asterisk/
COPY --from=build /var/log/asterisk/ /var/log/asterisk/
COPY --from=build /var/run/asterisk/ /var/run/asterisk/
COPY --from=build /var/spool/asterisk/ /var/spool/asterisk/
COPY --from=build /var/spool/asterisk/ /var/spool/asterisk/
COPY --from=build /usr/share/man/man8/ast* /usr/share/man/man8/autosupport /usr/share/man/man8/safe_asterisk /etc/asterisk/

COPY --from=rootfs / /

RUN groupadd --system asterisk && \
    useradd --system -d /var/lib/asterisk -g asterisk asterisk && \
    chown -R asterisk:asterisk  /etc/asterisk \
                                /var/lib/asterisk \
                                /var/log/asterisk \
                                /var/run/asterisk \
                                /var/spool/asterisk \
                                /usr/lib/asterisk && \
    chmod -R 750 /var/spool/asterisk
