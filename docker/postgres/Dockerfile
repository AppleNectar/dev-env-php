FROM postgres:15.4-bullseye
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE
ARG DB_LOCALE

ENV TZ ${CONTAINERS_TIMEZONE}

RUN localedef -i ${DB_LOCALE} -c -f UTF-8 -A /usr/share/locale/locale.alias ${DB_LOCALE}.UTF-8

ENV LANG ${DB_LOCALE}.UTF-8
