#!/bin/bash

set -euxo pipefail

apk add --update --no-cache \
    asterisk \
    asterisk-srtp \
    asterisk-sample-config \
    asterisk-sounds-en \
    asterisk-speex \
    asterisk-dahdi

mkdir -p /etc/asterisk/keys
