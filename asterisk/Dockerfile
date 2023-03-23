ARG BUILD_ARCH=amd64
# https://github.com/hassio-addons/addon-debian-base/releases
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/${BUILD_ARCH}:6.2.3


FROM $BUILD_FROM AS base

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

# https://pypi.org/project/asterisk_mbox_server/#history
ARG ASTERISK_MBOX_SERVER_VERSION="0.5.3"
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
        libvorbisenc2 \
        libvorbisfile3 \
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
        xmlstarlet \
        php \
        php-cli \
        # for googletts \
        perl \
        libwww-perl \
        liblwp-protocol-https-perl \
        sox \
        mpg123 \
        # for speech-recog \
        libjson-perl \
        libio-socket-ssl-perl \
        flac \
        # for downloading additional sounds \
        unzip; \
    \
    pip3 install --no-cache-dir asterisk_mbox_server=="${ASTERISK_MBOX_SERVER_VERSION}"; \
    \
    # Dependencies only used to build asterisk_mbox_server \
    apt-get purge -y --auto-remove gcc g++ libc6-dev python3-dev; \
    \
    rm -rf /var/lib/apt/lists/*


FROM base AS build

# Install dependencies
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
        autoconf \
        automake \
        build-essential \
        binutils-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libgsm1-dev \
        libogg-dev \
        libopus-dev \
        libopusfile-dev \
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
        procps \
        subversion \
        uuid-dev; \
    rm -rf /var/lib/apt/lists/*

# Taken from https://metadata.ftp-master.debian.org/changelogs/main/a/asterisk/unstable_changelog
# (replace all ~ with _ and remove final -)
ARG ASTERISK_OPUS_VERSION="20.1.0_dfsg+_cs6.12.40431414"
WORKDIR /usr/src/asterisk-opus
RUN curl -fsSL "https://salsa.debian.org/pkg-voip-team/asterisk/-/archive/upstream/${ASTERISK_OPUS_VERSION}/asterisk-upstream-${ASTERISK_OPUS_VERSION}.tar.gz?path=Xopus" | \
    tar --strip-components 2 -xz

# https://github.com/asterisk/asterisk/tags
# https://www.asterisk.org/downloads/asterisk/all-asterisk-versions/
ARG ASTERISK_VERSION="20.2.0"
WORKDIR /usr/src/asterisk
RUN curl -fsSL "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz" | \
    tar --strip-components 1 -xz

# copy codec_opus_open_source files
# res/* and include/asterisk/* are not needed as asterisk is new enough
RUN cp --verbose ../asterisk-opus*/codecs/* codecs; \
    cp --verbose ../asterisk-opus*/formats/* formats; \
    patch -p1 < ../asterisk-opus*/asterisk.patch

## Install app_rtsp_sip
WORKDIR /usr/src/app_rtsp_sip
COPY patches/app_rtsp_sip/*.patch ./
# https://github.com/tommyjlong/app_rtsp_sip/commits/master
ARG APP_RTSP_SIP_VERSION="d0fb18b4813e4ae8940029a8a62030443d9feaec"
ARG TARGETARCH
# hadolint ignore=DL3003,SC2164
RUN if [[ "${TARGETARCH}" == "amd64" || "${TARGETARCH}" == "i386" ]]; then \
        curl -fsSL "https://github.com/tommyjlong/app_rtsp_sip/archive/${APP_RTSP_SIP_VERSION}.tar.gz" | \
        tar --strip-components 1 -xz; \
        patch -p1 < disable_auth.patch; \
        patch -p1 < remove_sudo.patch; \
        cp -f app_rtsp_sip.c /usr/src/asterisk/apps; \
        cp -f rtsp_sip_links.sh /usr/src/asterisk; \
        cd /usr/src/asterisk; \
        ./rtsp_sip_links.sh; \
    fi

# Copy patches specific for this addon
COPY patches/asterisk/*.patch /usr/src/asterisk-patches/
WORKDIR /usr/src/asterisk
# Increase the number of format entries in SDPs to 128
RUN patch -p1 < /usr/src/asterisk-patches/increase_max_number_of_sdp_format_entries.patch

RUN \
    # Recreate the configure script as we patched it above for the new formats \
    ./bootstrap.sh; \
    \
    ./configure \
        --with-jansson-bundled \
        --with-pjproject-bundled \
        --with-opus \
        --with-opusfile \
        --with-resample \
        --without-asound \
        --without-bluetooth \
        --without-dahdi \
        --without-gtk2 \
        --without-jack \
        --without-portaudio \
        --without-postgres \
        --without-pri \
        --without-radius \
        --without-sdl \
        --without-ss7 \
        --without-tds \
        --without-unixodbc \
        --without-x11; \
    \
    make menuselect/menuselect menuselect-tree menuselect.makeopts; \
    # channels \
    menuselect/menuselect --disable-category MENUSELECT_CHANNELS \
        --enable chan_audiosocket \
        --enable chan_bridge_media \
        --enable chan_iax2 \
        --enable chan_pjsip \
        --enable chan_rtp \
        --enable chan_sip ; \
    # enable good things \
    menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts; \
    # applications \
    menuselect/menuselect --disable app_adsiprog menuselect.makeopts; \
    menuselect/menuselect --disable app_getcpeid menuselect.makeopts; \
    # call detail recording \
    menuselect/menuselect --disable cdr_sqlite3_custom menuselect.makeopts; \
    # call event logging \
    menuselect/menuselect --disable cel_sqlite3_custom menuselect.makeopts; \
    # formats \
    menuselect/menuselect --enable format_mp3 menuselect.makeopts; \
    # codecs \
    menuselect/menuselect --enable codec_a_mu menuselect.makeopts; \
    menuselect/menuselect --enable codec_adpcm menuselect.makeopts; \
    menuselect/menuselect --enable codec_alaw menuselect.makeopts; \
    menuselect/menuselect --enable codec_codec2 menuselect.makeopts; \
    menuselect/menuselect --enable codec_g722 menuselect.makeopts; \
    menuselect/menuselect --enable codec_g726 menuselect.makeopts; \
    menuselect/menuselect --enable codec_gsm menuselect.makeopts; \
    menuselect/menuselect --enable codec_ilbc menuselect.makeopts; \
    menuselect/menuselect --enable codec_resample menuselect.makeopts; \
    menuselect/menuselect --enable codec_speex menuselect.makeopts; \
    menuselect/menuselect --enable codec_ulaw menuselect.makeopts; \
    menuselect/menuselect --enable codec_opus_open_source menuselect.makeopts; \
    # pbx modules \
    menuselect/menuselect --disable pbx_spool menuselect.makeopts; \
    # resource modules \
    menuselect/menuselect --disable res_config_sqlite3 menuselect.makeopts; \
    menuselect/menuselect --disable res_monitor menuselect.makeopts; \
    menuselect/menuselect --disable res_adsi menuselect.makeopts; \
    # utilities \
    menuselect/menuselect --disable astdb2sqlite3 menuselect.makeopts; \
    menuselect/menuselect --disable astdb2bdb menuselect.makeopts; \
    # download more sounds \
    for i in CORE-SOUNDS-EN MOH-OPSOUND EXTRA-SOUNDS-EN; do \
        for j in ULAW ALAW G722 GSM SLN16; do \
            menuselect/menuselect --enable $i-$j menuselect.makeopts; \
        done; \
    done; \
    \
    # We require this for module format_mp3.so \
    contrib/scripts/get_mp3_source.sh

ENV INSTALL_DIR="/opt/asterisk"

RUN \
    # disable BUILD_NATIVE to avoid platform issues \
    # for some reason, this needs to be set just before calling make (see #128) \
    menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts; \
    # 1.5 jobs per core works out okay \
    JOBS=$(( $(nproc) + $(nproc) / 2 )); \
    make -j ${JOBS} all; \
    # install asterisk binaries and modules \
    DESTDIR="${INSTALL_DIR}" make install; \
    # install example configuration \
    DESTDIR="${INSTALL_DIR}" make samples

## Install chan-gongle
WORKDIR /usr/src/asterisk-chan-dongle
# https://github.com/wdoekes/asterisk-chan-dongle/commits/master
ARG CHAN_DONGLE_VERSION="503dba87d726854b74b49e70679e64e6e86d5812"
RUN curl -fsSL "https://github.com/wdoekes/asterisk-chan-dongle/archive/${CHAN_DONGLE_VERSION}.tar.gz" | \
    tar --strip-components 1 -xz
RUN ./bootstrap; \
    ./configure \
        DESTDIR="${INSTALL_DIR}/usr/lib/asterisk/modules" \
        --with-astversion="${ASTERISK_VERSION}" \
        --with-asterisk="/usr/src/asterisk/include"; \
    make all; \
    make install; \
    cp -f etc/dongle.conf "${INSTALL_DIR}/etc/asterisk/"

## Install googletts
WORKDIR /usr/src/asterisk-googletts
COPY patches/googletts/change_tmp_dir.patch .
# https://github.com/zaf/asterisk-googletts/commits/master
ARG GOOGLETTS_VERSION="5566ddc42e99d15cfaee2c4b8882e171ada2e479"
RUN curl -fsSL "https://github.com/zaf/asterisk-googletts/archive/${GOOGLETTS_VERSION}.tar.gz" | \
    tar --strip-components 1 -xz; \
    patch -p1 < change_tmp_dir.patch
RUN cp -f googletts.agi "${INSTALL_DIR}/var/lib/asterisk/agi-bin"

## Install speech-recog
WORKDIR /usr/src/asterisk-speech-recog
COPY patches/speech-recog/change_tmp_dir.patch .
# https://github.com/zaf/asterisk-speech-recog/commits/master
ARG SPEECH_RECOG_VERSION="dbc933bca1074514963a2294c52e617ef539a90a"
RUN curl -fsSL "https://github.com/zaf/asterisk-speech-recog/archive/${SPEECH_RECOG_VERSION}.tar.gz" | \
    tar --strip-components 1 -xz; \
    patch -p1 < change_tmp_dir.patch
RUN cp -f speech-recog.agi "${INSTALL_DIR}/var/lib/asterisk/agi-bin"

# Debian has a symlink from /var/run to /run, so here we move contents
# directly to /run. Otherwise we run into https://github.com/docker/buildx/issues/150.
RUN mv -f "${INSTALL_DIR}/var/run" "${INSTALL_DIR}/run"


FROM base

COPY --from=build /opt/asterisk/ /

COPY rootfs /

# Fix container failing to start some times
ENV S6_SERVICES_READYTIME=50
# Without this, the STDIN script never gets executed
ENV S6_CMD_WAIT_FOR_SERVICES=0

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/stdin.sh" ]

LABEL \
    org.opencontainers.image.title="Home Assistant Add-on: Asterisk" \
    org.opencontainers.image.description="PBX server for SIP devices like doorbells and phones." \
    org.opencontainers.image.source="https://github.com/TECH7Fox/asterisk-hass-addons" \
    org.opencontainers.image.licenses="MIT"
