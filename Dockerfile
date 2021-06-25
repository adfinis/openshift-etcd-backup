FROM registry.access.redhat.com/ubi8@sha256:77623387101abefbf83161c7d5a0378379d0424b2244009282acb39d42f1fe13

LABEL org.opencontainers.image.authors="Adfinis AG <https://adfinis.com>"
LABEL org.opencontainers.image.vendor="Adfinis"

RUN mkdir /scripts

ADD backup.sh /scripts

RUN chmod +x /scripts/backup.sh

CMD ["/scripts/backup.sh"]
