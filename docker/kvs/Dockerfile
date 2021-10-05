FROM redis:6.2.5-buster
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE
ARG REDIS_AUTH_PASS

ENV TZ ${CONTAINERS_TIMEZONE}
ENV REDIS_AUTH_PASS ${REDIS_AUTH_PASS}

# Package update and install
RUN apt update \
    && apt -y upgrade  \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["sh", "-c", "exec redis-server --requirepass \"${REDIS_AUTH_PASS}\""]