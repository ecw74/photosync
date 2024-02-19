# hadolint global ignore=DL3008,DL3015,DL3059

FROM alpine:3.19

VOLUME /mnt/input
VOLUME /mnt/output

ENV CRON ""
ENV OPTIONS ""

RUN apk --no-cache add exiftool \
    && apk add bash \
    && apk add flock

COPY --chmod=755 entrypoint.sh /opt/app/

CMD ["/opt/app/entrypoint.sh"]
