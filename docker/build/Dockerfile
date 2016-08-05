FROM php:5-apache

# Install common PHP extensions
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt soap mysqli pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install Ant, Git, wget
RUN apt-get update \
  && apt-get install -y ant git wget zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

# Install Node.js, Grunt
RUN apt-get update \
  && apt-get install -y npm \
  && npm install -g n \
  && n stable \
  && npm update -g npm \
  && npm install -g grunt-cli

# Install magento PHP extensions
RUN apt-get update && apt-get -y install \
    libxslt1-dev \
    libicu-dev \
    mysql-client \
    libmysqlclient-dev \
    && docker-php-ext-configure zip --enable-zip \
    && docker-php-ext-install intl mbstring xsl zip

# Install tools
RUN apt-get update && apt-get install -y \
    inotify-tools \
    locales \
    cron \
    supervisor \
  && localedef -i en_US -f UTF-8 en_US.UTF-8

# Install xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install dockerize
ENV DOCKERIZE_VERSION v0.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Clean up
RUN ["apt-get", "clean"]
RUN ["rm", "-rf", "/var/lib/apt/lists/*", "/tmp/*", "/var/tmp/*"]

# Activate mod_rewrite
RUN a2enmod rewrite

# Set umask to 002
RUN echo "session optional pam_umask.so" >> /etc/pam.d/common-session \
  && sed -i "s/UMASK\s\+022/UMASK   002/" /etc/login.defs

# Set memory limit
RUN echo "memory_limit=1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Set workdir
WORKDIR /app

# Set up entrypoint
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Copy scripts
COPY ./scripts /scripts

# Set up supervisord
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install crontab
COPY ./magento-cron /tmp/magento-cron
RUN cat /tmp/magento-cron | crontab - \
  && rm /tmp/magento-cron
