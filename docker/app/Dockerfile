FROM php:8.1-fpm-bullseye
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

# Install composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

# Package install
RUN apt-get update \
    && apt-get -y install \
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

# Create php.ini and fpm config
# * Comment out the user and group settings to remove the warning when running as non-root.
# * Instead, set listen.group to the group of the executing user.
RUN cp -i /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i -e "s|^;date.timezone =|date.timezone = ${CONTAINERS_TIMEZONE}|g" /usr/local/etc/php/php.ini \
    && sed -i -e "/^user = /s/user/;user/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -e "/^group = /s/group/;group/g" /usr/local/etc/php-fpm.d/www.conf \
    && cp -i /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "/^user = /s/user/;user/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "/^group = /s/group/;group/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "/^listen = /s/127.0.0.1:9000/9000/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "s/;listen.group = www-data/listen.group = ${WEB_USER_GROUP}/g" /usr/local/etc/php-fpm.d/zzz-www.conf \
    && sed -i -e "s/;listen.mode/listen.mode/g" /usr/local/etc/php-fpm.d/zzz-www.conf

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

USER ${WEB_USER_NAME}

WORKDIR /var/www/html/app