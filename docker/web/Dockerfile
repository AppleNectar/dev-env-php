FROM nginx:1.21
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE
ARG CONTAINERS_LANG
ARG WEB_USER_NAME
ARG WEB_USER_UID
ARG WEB_USER_GROUP
ARG WEB_USER_GID
ARG WEB_USER_SHELL

ENV TZ ${CONTAINERS_TIMEZONE}

# Package update and install
RUN apt update \
    && apt -y upgrade  \
    && apt -y install \
        wget \
        libnss3-tools \
        zip \
        unzip \
        locales \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/bin/mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 \
    && chmod +x /usr/bin/mkcert

# OS language setting
RUN sed -i -E "s/# (${CONTAINERS_LANG})/\1/" /etc/locale.gen \
    && locale-gen ${CONTAINERS_LANG} \
    && update-locale LANG=${CONTAINERS_LANG}

ENV LC_ALL ${CONTAINERS_LANG}

# Create dev user and application directory
RUN groupadd -g ${WEB_USER_GID} ${WEB_USER_GROUP} \
    && useradd -u ${WEB_USER_UID} -g ${WEB_USER_GROUP} -G www-data -s ${WEB_USER_SHELL} -m ${WEB_USER_NAME} \
    && mkdir -p /var/www/html/app \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /var/www/html \ 
    && chmod 775 /var/www/html/app

# Make self-certificate files and DH key parameter file for localhost
# * Want to get a browser certificate warning?
#   1. Execute command: docker compose cp web:/home/dev/rootCA.pfx ./
#   2. Install rootCA.pfx created in the project root on the system that uses the browser.
RUN mkcert -install \
    && cd /root/.local/share/mkcert/ \
    && openssl pkcs12 -export -inkey rootCA-key.pem -in rootCA.pem -out rootCA.pfx -passin pass:"" -passout pass:"" \
    && cp rootCA.pfx /home/${WEB_USER_NAME}/ \
    && chown ${WEB_USER_NAME}:${WEB_USER_GROUP} /home/${WEB_USER_NAME}/rootCA.pfx \
    && mkdir /etc/nginx/certs \
    && mkcert -cert-file /etc/nginx/certs/server.crt -key-file /etc/nginx/certs/server.key localhost 127.0.0.1 \
    && openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048 \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /etc/nginx/certs

## Copy nginx server config
COPY conf/default.conf /etc/nginx/conf.d/

# Configure nginx exec params
# - Change process execute user
# - Change log format(add self hostname)
# - Server token disable
# - gzip enable
# - Allow long server name
# - Change fast cgi buffer size
# - Change keppalive timeout
RUN NGINX_CONF_PATH=/etc/nginx/nginx.conf \
    # && sed -i -e "/^user /s/nginx/${WEB_USER_NAME}/g" ${NGINX_CONF_PATH} \
    && sed -i -e "/^user/s/user/#user/g" ${NGINX_CONF_PATH} \
    && sed -i -e 's/"$http_user_agent"/"$http_user_agent" "$host"/g' ${NGINX_CONF_PATH} \
    && sed -i -e "/^http {/a \    server_tokens off;" ${NGINX_CONF_PATH} \
    && sed -i -e "/#gzip/s/#//g" ${NGINX_CONF_PATH} \
    && sed -i -e "/gzip.*on/a \    server_names_hash_bucket_size 128;" ${NGINX_CONF_PATH} \
    && sed -i -e "/server_names_hash_bucket_size/a \    fastcgi_buffers 16 32k;" ${NGINX_CONF_PATH} \
    && sed -i -e "/fastcgi_buffers/a \    fastcgi_buffer_size 64k;" ${NGINX_CONF_PATH} \
    && sed -i -e "/fastcgi_buffer_size/a \    fastcgi_busy_buffers_size 64k;" ${NGINX_CONF_PATH} \
    && sed -i -e "/keepalive_timeout/s/65/5/g" ${NGINX_CONF_PATH} \
    && unset NGINX_CONF_PATH \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /var/cache/nginx \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /var/log/nginx \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /etc/nginx/conf.d \
    && touch /var/run/nginx.pid \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /var/run/nginx.pid

# Install node.js
COPY --from=node:lts-buster-slim /usr/local/bin /usr/local/bin
COPY --from=node:lts-buster-slim /usr/local/lib /usr/local/lib
COPY --from=node:lts-buster-slim /opt /opt

USER ${WEB_USER_NAME}

WORKDIR /var/www/html/app