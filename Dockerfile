# hadolint global ignore=DL3008,DL3015,DL3018,DL3059

FROM alpine:3.19

VOLUME /mnt/input
VOLUME /mnt/output

ENV CRON_1 ""
ENV CRON_2 ""
ENV SOURCE_PATH_1=/mnt/input_1
ENV SOURCE_PATH_2=/mnt/input_2
ENV DESTINATION_PATH=/mnt/output
ENV USER_ID=1000
ENV GROUP_ID=1000

RUN apk --no-cache add bash dcron exiftool flock su-exec

COPY --chmod=755 entrypoint.sh /opt/app/
COPY --chmod=755 move_media.sh /opt/app/

CMD ["/opt/app/entrypoint.sh"]
