FROM php:8.3-fpm-alpine

ENV PHPGROUP=laravel
ENV PHPUSER=laravel

RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER}

# Install supervisor
RUN apk add --no-cache supervisor

# Create supervisor directories
RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/run/supervisor \
    && mkdir -p /etc/supervisor/conf.d

# Install zip dependencies
RUN apk add --no-cache libzip-dev

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql exif zip

# Install GD extension
RUN apk add libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd

# Install Redis extension
RUN apk add coreutils
RUN apk add --no-cache pcre-dev $PHPIZE_DEPS \
        && pecl install redis \
        && docker-php-ext-enable redis.so \
        && apk del pcre-dev ${PHPIZE_DEPS}

# Add PHP configuration
ADD ./docker/confs/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini

# Add supervisor configuration
COPY ./docker/confs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create Laravel supervisor logs directory and set permissions
RUN mkdir -p /var/www/html/storage/logs/supervisor \
    && chown -R ${PHPUSER}:${PHPGROUP} /var/www/html/storage/logs/supervisor

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
