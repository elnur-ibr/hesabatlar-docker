FROM composer:2.8.10

ENV COMPOSERUSER=laravel
ENV COMPOSERGROUP=laravel

# Install zip dependencies
RUN apk add --no-cache libzip-dev

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql exif zip

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

RUN adduser -g ${COMPOSERGROUP} -s /bin/sh -D ${COMPOSERUSER}
