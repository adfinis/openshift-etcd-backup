FROM registry.access.redhat.com/ubi8-minimal:8.5-230

LABEL org.opencontainers.image.authors="Adfinis AG <https://adfinis.com>"
LABEL org.opencontainers.image.vendor="Adfinis"

COPY backup.sh /usr/local/bin/backup.sh

RUN microdnf update -y && rm -rf /var/cache/yum
RUN microdnf install findutils shadow-utils sudo -y && microdnf clean all

# Add ocp backup NFS user if required
# RUN groupadd -g 1234 backupuser
# RUN useradd -m -u 1234 -g 1234 -o -s /bin/sh backupuser

CMD ["/usr/local/bin/backup.sh"]
