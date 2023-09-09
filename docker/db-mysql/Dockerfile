FROM mysql:8.0-debian
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE

ENV TZ ${CONTAINERS_TIMEZONE}

# Create log files
RUN mkdir /var/log/mysql \
    && touch /var/log/mysql/general.log \
    && touch /var/log/mysql/slow.log \
    && touch /var/log/mysql/error.log \
    && chown -R mysql:mysql /var/log/mysql \
    && chmod -R 774 /var/log/mysql

RUN echo "use mysql;" > /docker-entrypoint-initdb.d/0_timezone.sql \
    && mysql_tzinfo_to_sql /usr/share/zoneinfo >> /docker-entrypoint-initdb.d/0_timezone.sql

COPY conf/ /etc/mysql/conf.d/
COPY scripts/1_init.sh /docker-entrypoint-initdb.d/

RUN chmod 644 /etc/mysql/conf.d/* \
    && chmod 644 /docker-entrypoint-initdb.d/1_init.sh

RUN chown mysql:mysql /var/run/mysqld