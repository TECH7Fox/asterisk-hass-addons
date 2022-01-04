ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:edge
FROM $BUILD_FROM

ENV LANG C.UTF-8

COPY rootfs /

# Install and setup Asterisk
RUN /install.sh && rm -f /install.sh

CMD [ "/run.sh" ]