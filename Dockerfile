FROM registry.access.redhat.com/ubi9-minimal:9.3-1475

LABEL org.opencontainers.image.authors="Adfinis AG <https://adfinis.com>"
LABEL org.opencontainers.image.vendor="Adfinis"

COPY backup.sh /usr/local/bin/backup.sh

RUN microdnf update -y && rm -rf /var/cache/yum
RUN microdnf install findutils -y && microdnf clean all

CMD ["/usr/local/bin/backup.sh"]
