FROM php:8.3-fpm-alpine

ENV PHPGROUP=laravel
ENV PHPUSER=laravel

RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER}

RUN sed -i "s/user = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = ${PHPGROUP}/g" /usr/local/etc/php-fpm.d/www.conf

# Install Node.js and npm
RUN apk add --no-cache nodejs npm

#php extension
RUN docker-php-ext-install pdo pdo_mysql exif

#for gd php extension
RUN apk add libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd

#for redis php extension
RUN apk add coreutils

RUN apk add --no-cache pcre-dev $PHPIZE_DEPS \
        && pecl install redis \
        && docker-php-ext-enable redis.so \
        && apk del pcre-dev ${PHPIZE_DEPS}

ADD ./docker/confs/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
