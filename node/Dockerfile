FROM ubuntu:16.04
MAINTAINER "Piero Giusti <pierophp@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Upgrade
RUN apt update && \
    apt upgrade -y && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Tools
RUN apt update && \
    apt install -y wget curl vim nano less unzip git mlocate && \
    apt clean && rm -rf /var/lib/apt/lists/*

#Add user
RUN useradd -ms /bin/bash dev -G sudo,ssh && echo 'dev:123' | chpasswd

# Nginx
# Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN unlink /etc/nginx/sites-enabled/default
ADD nginx/default /etc/nginx/sites-enabled/default
RUN chown -R www-data:www-data /var/www/

RUN chown -R dev:dev /var/www/

# Supervisor
RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf

# NPM
RUN apt-get update && \
    apt-get install -y npm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Node
RUN npm install -g n && \
    n stable && \
	npm install -g strongloop && \
	npm install -g strong-pm && \
	npm install -g nodemon && \
	npm install -g knex && \
	npm install -g bower && \
	npm cache clear
	
#Update locate
RUN updatedb

WORKDIR /var/www/

EXPOSE 80

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
