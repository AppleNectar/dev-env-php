FROM postgres:15.4-bullseye
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_LANG
ARG CONTAINERS_TIMEZONE

ENV TZ ${CONTAINERS_TIMEZONE}

# OS language setting
RUN sed -i -E "s/# (${CONTAINERS_LANG})/\1/" /etc/locale.gen \
    && locale-gen ${CONTAINERS_LANG} \
    && update-locale LANG=${CONTAINERS_LANG}

ENV LC_ALL ${CONTAINERS_LANG}
