FROM ubuntu:14.04
MAINTAINER "Piero Giusti <pierophp@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Upgrade
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Tools
RUN apt-get update && \
    apt-get install -y wget curl vim nano less unzip git mlocate && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

#Config sudo
RUN sed -i s/ALL$/NOPASSWD:ALL/g /etc/sudoers

#Add user
RUN useradd -ms /bin/bash handview -G sudo,ssh && echo 'handview:123' | chpasswd

## PHP 7 Dependencies
# persistent / runtime deps
RUN apt-get update && \
    apt-get install -y ca-certificates libpcre3 librecode0 libsqlite3-0 libxml2 --no-install-recommends && \
    rm -r /var/lib/apt/lists/*

# phpize deps
RUN apt-get update && \
    apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends && \
    rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data
ENV PHP_VERSION 7.0.0beta2

RUN buildDeps=" \
		$PHP_EXTRA_BUILD_DEPS \
		libcurl4-openssl-dev \
		libpcre3-dev \
		libreadline6-dev \
		librecode-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		xz-utils \
	" \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -SL "https://downloads.php.net/~ab/php-$PHP_VERSION.tar.xz" -o php.tar.xz \
	&& mkdir -p /usr/src/php \
	&& tar -xof php.tar.xz -C /usr/src/php --strip-components=1 \
	&& rm php.tar.xz* \
	&& cd /usr/src/php \
	&& ./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--disable-cgi \
		--enable-mysqlnd \
		--with-curl \
		--with-openssl \
		--with-pcre \
		--with-readline \
		--with-recode \
		--with-zlib \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
	&& make clean

# PHP 5
# RUN echo "deb http://repos.zend.com/zend-server/early-access/php7/repos ubuntu/" >> /etc/apt/sources.list && \
#    apt-get update && \
#    apt-get install -y php5-fpm php5-cli php5-gd php5-mcrypt php5-mysql php5-curl php5-dev swig && \
#    apt-get clean && rm -rf /var/lib/apt/lists/* && \
#    unlink /etc/php/7.0/fpm/pool.d/www.conf && \
#    unlink /etc/php/7.0/cli/php.ini && \
#    unlink /etc/php/7.0/fpm/php.ini

#ADD php/fpm.conf /etc/php/7.0/fpm/pool.d/fpm.conf
ADD php/fpm.conf /usr/local/etc/php-fpm.conf
ADD php/php.ini /etc/php/7.0/fpm/php.ini
ADD php/php.ini /etc/php/7.0/cli/php.ini


#PHP Composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo 'error_log=/var/log/php/fpm.log' >> /etc/php/7.0/fpm/php.ini && \
    echo 'error_log=/var/log/php/cli.log' >>  /etc/php/7.0/cli/php.ini && \
    mkdir /var/log/php/ && \
    touch /var/log/php/cli.log /var/log/php/cgi.log && \
    chown www-data:www-data /var/log/php/cgi.log /var/log/php/cli.log

# Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN unlink /etc/nginx/sites-enabled/default
ADD nginx/default /etc/nginx/sites-enabled/default
RUN mkdir /var/www/
RUN chown -R www-data:www-data /var/www/

# MySql
RUN apt-get update && \
    echo "mysql-server mysql-server/root_password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections && \
    apt-get install -y mysql-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf
RUN chown -R mysql:mysql /var/lib/mysql

# SSHD
RUN apt-get update && \
    apt-get install -y openssh-client openssh-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# PHPMyAdmin
ENV VERSION 4.4.3
RUN mkdir -p /var/www/phpmyadmin && \
    cd /var/www/phpmyadmin && \
    wget -O - "http://www.sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.gz/download" | tar --strip-components=1 -x -z && \
    rm -rf *.md .coveralls.yml ChangeLog composer.json config.sample.inc.php DCO doc examples phpunit.* README RELEASE-DATE-* setup
ADD nginx/config.inc.php /var/www/phpmyadmin/

# Avconv && Mp4v2 && DVDAuthor
RUN apt-get update && \
    apt-get install -y libav-tools mp4v2-utils dvdauthor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Supervisor
RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ADD supervisor/php5-fpm.conf /etc/supervisor/conf.d/php5-fpm.conf
ADD supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf
ADD supervisor/sshd.conf /etc/supervisor/conf.d/sshd.conf

#Mega Client
ENV LD_LIBRARY_PATH /usr/local/lib

RUN apt-get update && \
    apt-get install -y libcrypto++-dev dh-autoreconf sqlite3 libsqlite3-dev libc-ares-dev libcurl4-openssl-dev libfreeimage3 libfreeimage-dev libncurses5-dev libreadline-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/meganz/sdk.git ~/mega_sdk && \
    cd ~/mega_sdk && \
    sh autogen.sh && \
    ./configure --enable-php && \
    make && \
    make install

#Update locate
RUN updatedb

WORKDIR /var/www/handview/

# isso faz que nao seja comitado
# VOLUME /var/www/
# VOLUME /var/lib/mysql/

EXPOSE 80
EXPOSE 22
EXPOSE 3306

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
