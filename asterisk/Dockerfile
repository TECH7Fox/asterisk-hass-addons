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

ENV DESTDIR="/opt/asterisk"

WORKDIR /usr/src/asterisk-opus
RUN curl -fsSL "https://salsa.debian.org/pkg-voip-team/asterisk/-/archive/upstream/18.10.1_dfsg+_cs6.10.40431411/asterisk-upstream-18.10.1_dfsg+_cs6.10.40431411.tar.gz?path=Xopus" | \
    tar --strip-components 2 -xz

WORKDIR /usr/src/asterisk
RUN curl -fsSL "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz" | \
    tar --strip-components 1 -xz

# copy codec_opus_open_source files
# res/* and include/asterisk/* are not needed as asterisk is new enough
RUN cp --verbose ../asterisk-opus*/codecs/* codecs; \
    cp --verbose ../asterisk-opus*/formats/* formats; \
    patch -p1 < ../asterisk-opus*/asterisk.patch

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
    # disable BUILD_NATIVE to avoid platform issues \
    menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts; \
    # channels \
    menuselect/menuselect --disable-category MENUSELECT_CHANNELS \
        --enable chan_audiosocket \
        --enable chan_bridge_media \
        --enable chan_iax2 \
        --enable chan_pjsip \
        --enable chan_rtp; \
    # enable good things \
    menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts; \
    # applications \
    menuselect/menuselect --disable app_ices menuselect.makeopts; \
    menuselect/menuselect --disable app_adsiprog menuselect.makeopts; \
    menuselect/menuselect --disable app_url menuselect.makeopts; \
    menuselect/menuselect --disable app_image menuselect.makeopts; \
    menuselect/menuselect --disable app_nbscat menuselect.makeopts; \
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
    contrib/scripts/get_mp3_source.sh; \
    # 1.5 jobs per core works out okay \
    JOBS=$(( $(nproc) + $(nproc) / 2 )); \
    make -j ${JOBS} all; \
    # install asterisk binaries and modules \
    make install; \
    # install example configuration \
    make samples

# set runuser and rungroup
RUN sed -i -E 's/^;(run)(user|group)/\1\2/' "${DESTDIR}/etc/asterisk/asterisk.conf"

RUN chown -R asterisk:asterisk "${DESTDIR}"

# Otherwise we run into https://github.com/docker/buildx/issues/150
RUN mv "${DESTDIR}/var/run" "${DESTDIR}/run"

RUN chmod -R 750 "${DESTDIR}/var/spool/asterisk"

# remove the man pages
RUN rm -rf "${DESTDIR}/share"


FROM scratch AS rootfs

COPY --from=build /opt/asterisk/ /

COPY rootfs /


FROM base

COPY --from=rootfs / /
