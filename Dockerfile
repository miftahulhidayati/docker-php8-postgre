FROM php:8.2-apache

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
   build-essential \
   libpng-dev \
   libjpeg62-turbo-dev \
   libfreetype6-dev \
   locales \
   zip \
   jpegoptim optipng pngquant gifsicle \
   vim \
   unzip \
   git \
   curl \
   # pdo_pgsql require libpq-dev
   libpq-dev \ 
   # mbstring require libonig-dev
   libonig-dev \
   # zip require libzip-dev
   libzip-dev \
   # gmp require libgmp-dev
   libgmp-dev \
   # intl require libicu-dev \
   libicu-dev \
   iputils-ping \
   telnet \ 
   nodejs \ 
   npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_pgsql pgsql mbstring zip exif pcntl gmp
#RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-configure intl 
RUN docker-php-ext-install gd intl

# Install Xdebug
RUN pecl install xdebug \
   && docker-php-ext-enable xdebug \
   && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
   && echo "xdebug.remote_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini 


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# enable mod rewrite
RUN a2enmod rewrite \
   && /etc/init.d/apache2 restart

WORKDIR /var/www/html
# Copy the PHP code file in /app into the container at /var/www/html
COPY ../app .