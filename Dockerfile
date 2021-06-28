FROM registry.access.redhat.com/ubi8-minimal@sha256:0ccb9988abbc72d383258d58a7f519a10b637d472f28fbca6eb5fab79ba82a6b

LABEL org.opencontainers.image.authors="Adfinis AG <https://adfinis.com>"
LABEL org.opencontainers.image.vendor="Adfinis"

COPY backup.sh /usr/local/bin/backup.sh

RUN microdnf install findutils -y && microdnf clean all

CMD ["/usr/local/bin/backup.sh"]
