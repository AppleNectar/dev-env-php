FROM mysql:8.0
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE

ENV TZ ${CONTAINERS_TIMEZONE}

# Package update and install
RUN apt-get update \
    && apt-get -y upgrade  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "use mysql;" > /docker-entrypoint-initdb.d/0_timezone.sql \
    && mysql_tzinfo_to_sql /usr/share/zoneinfo >> /docker-entrypoint-initdb.d/0_timezone.sql

COPY conf/ /etc/mysql/conf.d/
COPY scripts/1_init.sh /docker-entrypoint-initdb.d/

RUN chmod 644 /etc/mysql/conf.d/* \
    && chmod 644 /docker-entrypoint-initdb.d/1_init.sh

RUN chown mysql:mysql /var/run/mysqld