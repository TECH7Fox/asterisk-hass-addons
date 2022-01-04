ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --update \
      asterisk \
      asterisk-srtp \
      asterisk-sample-config \
      asterisk-sounds-en \
      asterisk-speex \
      asterisk-dahdi

## Setup Asterisk
RUN asterisk -U asterisk \
&& sleep 5 \
&& pkill -9 asterisk \
&& pkill -9 astcanary \
&& sleep 2 \

## Clean up and add fax
RUN rm -rf /var/run/asterisk/* \
&& mkdir -p /var/spool/asterisk/fax \
&& chown -R asterisk: /var/spool/asterisk/fax \
&& truncate -s 0 /var/log/asterisk/messages \
                 /var/log/asterisk/queue_log \
&& rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/* \
&& mkdir /etc/asterisk/keys

# Copy data for add-on
COPY run.sh /
COPY rootfs /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]