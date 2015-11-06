FROM debian:jessie

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

#Add user
RUN useradd -ms /bin/bash dev -G sudo,ssh && echo 'dev:123' | chpasswd

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.6-1~jessie

# Nginx
RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN unlink /etc/nginx/sites-enabled/default
ADD nginx/default /etc/nginx/sites-enabled/default

RUN chown -R dev:dev /var/www/

# MySql
RUN apt-get update && \
    echo "mysql-server mysql-server/root_password password" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections && \
    apt-get install -y mysql-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN sed -i 's/^key_buffer\s*=/key_buffer_size =/' /etc/mysql/my.cnf
RUN chown -R mysql:mysql /var/lib/mysql

# PHPMyAdmin
ENV VERSION 4.5.1
RUN mkdir -p /var/www/phpmyadmin && \
    cd /var/www/phpmyadmin && \
    wget "https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.zip" && \
    unzip phpMyAdmin-${VERSION}-all-languages.zip && \
    mv phpMyAdmin-${VERSION}-all-languages/* /var/www/phpmyadmin && \
    rm -rf phpMyAdmin-${VERSION}-all-languages/ && \
    rm -rf phpMyAdmin-${VERSION}-all-languages.zip && \
    rm -rf *.md .coveralls.yml ChangeLog composer.json config.sample.inc.php DCO doc examples phpunit.* README RELEASE-DATE-* setup
ADD nginx/config.inc.php /var/www/phpmyadmin/


# Supervisor
RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
ADD supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf

## PHP 7 Dependencies
# persistent / runtime deps
RUN apt-get update && \
    apt-get install -y libpcre3 librecode0 libsqlite3-0 libxml2 --no-install-recommends && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# phpize deps
RUN apt-get update && \
    apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends && \
    rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data
ENV PHP_VERSION 7.0.0RC6

#PHP Build Deps
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
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN curl -SL "https://downloads.php.net/~ab/php-$PHP_VERSION.tar.xz" -o php.tar.xz \
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
    --enable-mbstring \
    --enable-pdo \
    --enable-soap \
		--with-curl \
		--with-openssl \
		--with-readline \
		--with-recode \
		--with-zlib \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --enable-opcache \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
	&& make clean

ADD php/fpm.conf /usr/local/etc/php-fpm.conf
ADD php/php.ini /usr/local/etc/php/conf.d/php.ini

#PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir /var/log/php/ && \
    touch /var/log/php/fpm.log && \
    chown www-data:www-data /var/log/php/fpm.log && \
    mkdir /tmp/sessions && \
    chown -R dev:dev /tmp/sessions && \
    chmod 777 -R  /tmp/sessions

#PHPRedis
RUN cd /tmp && \
    git clone -b php7 https://github.com/phpredis/phpredis.git && \
    cd /tmp/phpredis && \
    phpize && \
    ./configure && \
    make && make install && \
    rm -Rf /tmp/phpredis


#Update locate
RUN updatedb

WORKDIR /var/www/

EXPOSE 80
EXPOSE 3306

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
