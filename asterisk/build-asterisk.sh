#!/bin/bash

# This modified build script is based on a version found in this project:
# https://github.com/andrius/asterisk
#
# The MIT License (MIT)
#
# Copyright (c) 2016 Andrius Kairiukstis

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

./configure --with-resample --with-jansson-bundled --with-pjproject-bundled

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
sed -i -E 's/^;(run)(user|group)/\1\2/' /etc/asterisk/asterisk.conf
