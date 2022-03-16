FROM registry.access.redhat.com/ubi8-minimal:8.5-240

LABEL org.opencontainers.image.authors="Adfinis AG <https://adfinis.com>"
LABEL org.opencontainers.image.vendor="Adfinis"

COPY backup.sh /usr/local/bin/backup.sh

RUN microdnf update -y && rm -rf /var/cache/yum
RUN microdnf install findutils -y && microdnf clean all

CMD ["/usr/local/bin/backup.sh"]
