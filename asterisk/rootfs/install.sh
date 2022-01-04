#!/bin/bash

set -euxo pipefail

apk add --update \
    asterisk \
    asterisk-srtp \
    asterisk-sample-config \
    asterisk-sounds-en \
    asterisk-speex \
    asterisk-dahdi

asterisk -U asterisk

sleep 5
pkill -9 asterisk
pkill -9 astcanary
sleep 2
mkdir -p /var/spool/asterisk/fax
chown -R asterisk: /var/spool/asterisk/fax
truncate -s 0 /var/log/asterisk/messages \
    /var/log/asterisk/queue_log
rm -rf /var/cache/apk/* \
    /tmp/* \
    /var/tmp/* \
    mkdir /etc/asterisk/keys
