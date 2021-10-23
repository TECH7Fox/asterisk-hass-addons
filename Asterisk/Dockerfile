ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install requirements for add-on
RUN apk add --update \
      asterisk \
      asterisk-sample-config \
      openssl \
&& asterisk -U asterisk \
&& sleep 5 \
&& pkill -9 asterisk \
&& pkill -9 astcanary \
&& sleep 2 \
&& rm -rf /var/run/asterisk/* \
&& mkdir -p /var/spool/asterisk/fax \
&& chown -R asterisk: /var/spool/asterisk/fax \
&& truncate -s 0 /var/log/asterisk/messages \
                 /var/log/asterisk/queue_log \
&&  rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/* \
&& mkdir /etc/asterisk/keys

# Set add-on persistent data directory
WORKDIR /data

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]