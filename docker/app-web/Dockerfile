FROM php:8.1-apache-bullseye
LABEL maintainer="AppleNectar"

SHELL [ "/bin/bash", "-oeux", "pipefail", "-c" ]

ARG CONTAINERS_TIMEZONE
ARG CONTAINERS_LANG
ARG WEB_USER_NAME
ARG WEB_USER_UID
ARG WEB_USER_GROUP
ARG WEB_USER_GID
ARG WEB_USER_SHELL
ARG ENABLE_XDBUG

ENV TZ ${CONTAINERS_TIMEZONE}

# Package install
RUN apt-get update \
    && apt-get -y install \
        wget \
        git \
        libonig-dev \
        libedit-dev \
        libpng-dev \
        libjpeg-dev \
        libxml2-dev \
        libfreetype6-dev \
        libzip-dev \
        zip \
        unzip \
        locales \
        zip \
        unzip \
        locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# OS language setting
RUN sed -i -E "s/# (${CONTAINERS_LANG})/\1/" /etc/locale.gen \
    && locale-gen ${CONTAINERS_LANG} \
    && update-locale LANG=${CONTAINERS_LANG}

ENV LC_ALL ${CONTAINERS_LANG}

# Create dev user and application directory
RUN groupadd -g ${WEB_USER_GID} ${WEB_USER_GROUP} \
    && useradd -u ${WEB_USER_UID} -g ${WEB_USER_GROUP} -G www-data -s ${WEB_USER_SHELL} -m ${WEB_USER_NAME} \
    && mkdir /var/www/html/app \
    && chown -R ${WEB_USER_NAME}:${WEB_USER_GROUP} /var/www/html \
    && chmod 775 /var/www/html/app

# Create php.ini
RUN cp -i /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i -e "s|^;date.timezone =|date.timezone = ${CONTAINERS_TIMEZONE}|g" /usr/local/etc/php/php.ini

# Enable Apache modules
RUN a2enmod rewrite

# Configure Apache params
RUN APACHE_CONF_PATH=/etc/apache2/sites-available/000-default.conf \
    && sed -i -e "/#ServerName/a \        ServerName localhost" ${APACHE_CONF_PATH} \
    && sed -i -e "s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/app/g" ${APACHE_CONF_PATH} \
    && echo "ServerName localhost" >> /etc/apache2/conf-available/fqdn.conf

# Enable and disable Apache configs
RUN a2dissite default-ssl \
    && a2enconf fqdn

# Install composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Install php extensions
RUN pecl install redis \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install \
        mbstring \
        bcmath \
        intl \
        pdo_mysql \
        simplexml \
        xml \
        zip \
    && echo 'extension=redis.so' > /usr/local/etc/php/conf.d/phpredis.ini

# Install xdebug
RUN if ${ENABLE_XDBUG}; then \
        pecl install xdebug; \
        docker-php-ext-enable xdebug; \
        touch /var/log/xdebug.log; \
        chmod 664 /var/log/xdebug.log; \
        chown root:${WEB_USER_GROUP} /var/log/xdebug.log; \
    fi

COPY conf/xdebug.ini /usr/local/etc/php/conf.d/

# Install node.js
COPY --from=node:lts-buster-slim /usr/local/bin /usr/local/bin
COPY --from=node:lts-buster-slim /usr/local/lib /usr/local/lib
COPY --from=node:lts-buster-slim /opt /opt

USER ${WEB_USER_NAME}

WORKDIR /var/www/html/app
