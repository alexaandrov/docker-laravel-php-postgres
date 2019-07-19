FROM php:7.3-fpm

# Installing dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    libpq-dev \
    rsync

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Installing extensions
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo_pgsql pgsql
RUN docker-php-ext-install mbstring zip exif pcntl bcmath opcache
RUN docker-php-ext-install gd

# Allow Composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Installing composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer global require hirak/prestissimo --no-plugins --no-scripts

# Setting locales
RUN echo en_US.UTF-8 UTF-8 > /etc/locale.gen && locale-gen

WORKDIR /tmp/app/cache

# Installing composer dependencies
COPY ["composer.json", "composer.lock", "./"]
RUN composer install --prefer-dist --no-scripts --no-autoloader

COPY .build/php/entrypoint.sh /usr/local/bin/docker-entrypoint

WORKDIR /app

COPY . .

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]