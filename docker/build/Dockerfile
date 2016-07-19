FROM alexcheng/magento2

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

# Install locales
RUN apt-get update \
    && apt-get install -y locales \
    && localedef -i en_US -f UTF-8 en_US.UTF-8

# Install ruby
RUN apt-get update \
    && apt-get install -y ruby ruby-dev \
    && gem install compass

# Install bower
RUN npm install -g bower

# Enable supervisord
RUN apt-get update && apt-get install -y openssh-server apache2 supervisor
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# Install inotify-tools
RUN apt-get update && apt-get install -y inotify-tools

# Clean up
RUN ["apt-get", "clean"]
RUN ["rm", "-rf", "/var/lib/apt/lists/*", "/tmp/*", "/var/tmp/*"]

WORKDIR /app

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["/usr/bin/supervisord"]

COPY ./scripts /scripts

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
