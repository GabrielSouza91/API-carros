FROM php:8.2-fpm

# Instalar dependências
RUN apt-get update && apt-get install -y \
  git \
  curl  \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libgd-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  libcurl4-openssl-dev \
  pkg-config \
  unzip \
  firebird-dev \
  libicu-dev \
  libpq-dev

# Limpar o cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Configuração de dependências do PHP
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_firebird mbstring exif pcntl bcmath gd sockets intl pdo_pgsql pdo_mysql

# Instalar opcache
RUN docker-php-ext-install opcache
COPY ./deployment/opache/opache.ini /usr/local/etc/php/conf.d/opcache.ini

# Instalar e habilitar redis
RUN pecl install -o -f redis \
  && rm -rf /tmp/pear \
  && docker-php-ext-enable redis

# Instalação do composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock ./
COPY . .

RUN composer clearcache
RUN composer install
RUN composer dump-autoload --optimize
RUN chown -R www-data:www-data storage bootstrap/cache
