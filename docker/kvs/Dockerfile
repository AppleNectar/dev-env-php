FROM redis:6.2-bullseye
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE
ARG REDIS_AUTH_PASS

ENV TZ ${CONTAINERS_TIMEZONE}
ENV REDIS_AUTH_PASS ${REDIS_AUTH_PASS}

CMD ["sh", "-c", "exec redis-server --requirepass \"${REDIS_AUTH_PASS}\""]