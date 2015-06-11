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

# PHP
RUN apt-get update && \
    apt-get install -y php5-fpm php5-cli php5-gd php5-mcrypt php5-mysql php5-curl php5-dev swig && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    unlink /etc/php5/fpm/pool.d/www.conf && \
    unlink /etc/php5/cli/php.ini && \
    unlink /etc/php5/fpm/php.ini

ADD php/fpm.conf /etc/php5/fpm/pool.d/fpm.conf    
ADD php/php.ini /etc/php5/fpm/php.ini    
ADD php/php.ini /etc/php5/cli/php.ini    


#PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo 'error_log=/var/log/php5/fpm.log' >> /etc/php5/fpm/php.ini && \
    echo 'error_log=/var/log/php5/cli.log' >>  /etc/php5/cli/php.ini && \
    mkdir /var/log/php5/ && \
    touch /var/log/php5/cli.log /var/log/php5/cgi.log && \
    chown www-data:www-data /var/log/php5/cgi.log /var/log/php5/cli.log    

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

# Avconv && Mp4v2
RUN apt-get update && \ 
    apt-get install -y libav-tools mp4v2-utils  && \
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