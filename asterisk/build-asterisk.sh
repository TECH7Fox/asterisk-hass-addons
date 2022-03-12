#!/bin/bash
PROGNAME=$(basename $0)

if test -z ${ASTERISK_VERSION}; then
    echo "${PROGNAME}: ASTERISK_VERSION required" >&2
    exit 1
fi

set -euxo pipefail

mkdir /usr/src/asterisk
cd /usr/src/asterisk

curl -vsLfS http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz |
    tar --strip-components 1 -xz

# 1.5 jobs per core works out okay
: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}

./configure --with-resample --with-jansson-bundled --with-pjproject-bundled --prefix=/opt/asterisk

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
#menuselect/menuselect --disable-category MENUSELECT_CORE_SOUNDS menuselect.makeopts
#menuselect/menuselect --disable-category MENUSELECT_MOH menuselect.makeopts
#menuselect/menuselect --disable-category MENUSELECT_EXTRA_SOUNDS menuselect.makeopts

make -j ${JOBS} all

#install asterisk binaries and modules
make install

# install example configuration
make samples

# set runuser and rungroup
sed -i -E 's/^;(run)(user|group)/\1\2/' /opt/asterisk/etc/asterisk/asterisk.conf
