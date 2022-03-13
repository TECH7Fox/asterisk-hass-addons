#!/bin/bash

# This modified build script is based on a version found in this project:
# https://github.com/andrius/asterisk
# Licensed under the MIT license

PROGNAME=$(basename "$0")

if test -z "${ASTERISK_VERSION}"; then
    echo "${PROGNAME}: ASTERISK_VERSION required" >&2
    exit 1
fi

set -euxo pipefail

INSTALL_DIR="/opt/asterisk"
export DEBIAN_FRONTEND=noninteractive

apt-get update

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
    uuid-dev

mkdir /usr/src/asterisk-opus
cd /usr/src/asterisk-opus

curl -fsSL "https://salsa.debian.org/pkg-voip-team/asterisk/-/archive/upstream/18.10.1_dfsg+_cs6.10.40431411/asterisk-upstream-18.10.1_dfsg+_cs6.10.40431411.tar.gz?path=Xopus" |
    tar --strip-components 2 -xz

mkdir /usr/src/asterisk
cd /usr/src/asterisk

curl -fsSL "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz" |
    tar --strip-components 1 -xz

# copy codec_opus_open_source files
# res/* and include/asterisk/* are not needed as asterisk is new enough
cp --verbose ../asterisk-opus*/codecs/* codecs
cp --verbose ../asterisk-opus*/formats/* formats
patch -p1 < ../asterisk-opus*/asterisk.patch

# 1.5 jobs per core works out okay
: "${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}"

# Recreate the configure script as we patched it above for the new formats
./bootstrap.sh

./configure --prefix="${INSTALL_DIR}" \
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
            --without-x11

make menuselect/menuselect menuselect-tree menuselect.makeopts

# disable BUILD_NATIVE to avoid platform issues
menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts

# channels
menuselect/menuselect --disable-category MENUSELECT_CHANNELS \
                      --enable chan_audiosocket \
                      --enable chan_bridge_media \
                      --enable chan_iax2 \
                      --enable chan_pjsip \
                      --enable chan_rtp \
                      --enable chan_sip 

# enable good things
menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts

# formats
menuselect/menuselect --enable format_mp3 menuselect.makeopts

# codecs
menuselect/menuselect --enable codec_opus_open_source menuselect.makeopts

# download more sounds
for i in CORE-SOUNDS-EN MOH-OPSOUND EXTRA-SOUNDS-EN; do
    for j in ULAW ALAW G722 GSM SLN16; do
        menuselect/menuselect --enable $i-$j menuselect.makeopts
    done
done

# we don't need any sounds in docker, they will be mounted as volume
# menuselect/menuselect --disable-category MENUSELECT_CORE_SOUNDS menuselect.makeopts
# menuselect/menuselect --disable-category MENUSELECT_MOH menuselect.makeopts
# menuselect/menuselect --disable-category MENUSELECT_EXTRA_SOUNDS menuselect.makeopts

# We require this for module format_mp3.so
contrib/scripts/get_mp3_source.sh

make -j ${JOBS} all

# install asterisk binaries and modules
make install

# install example configuration
make samples

# set runuser and rungroup
sed -i -E 's/^;(run)(user|group)/\1\2/' "${INSTALL_DIR}/etc/asterisk/asterisk.conf"

chown -R asterisk:asterisk "${INSTALL_DIR}"

mv "${INSTALL_DIR}/var/run" "${INSTALL_DIR}/run" # otherwise we run into https://github.com/docker/buildx/issues/150

chmod -R 750 "${INSTALL_DIR}/var/spool/asterisk"

# remove the man pages
rm -rf "${INSTALL_DIR}/share"
