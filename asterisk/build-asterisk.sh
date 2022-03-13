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
    build-essential \
    binutils-dev \
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
    portaudio19-dev \
    procps \
    unixodbc-dev \
    uuid-dev

mkdir /usr/src/asterisk
cd /usr/src/asterisk

curl -fsSL "http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz" |
    tar --strip-components 1 -xz

# 1.5 jobs per core works out okay
: "${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}"

./configure --prefix="${INSTALL_DIR}" --with-resample --with-jansson-bundled --with-pjproject-bundled

make menuselect/menuselect menuselect-tree menuselect.makeopts

# disable BUILD_NATIVE to avoid platform issues
menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts

# enable good things
menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts

# codecs
menuselect/menuselect --enable codec_opus menuselect.makeopts
# menuselect/menuselect --enable codec_silk menuselect.makeopts

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
