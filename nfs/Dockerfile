FROM ubuntu:14.04
MAINTAINER "Piero Giusti <pierophp@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Upgrade
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# NFS Server
RUN apt-get update && \
    apt-get install -y nfs-kernel-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

    # Supervisor
RUN apt-get update && \
    apt-get install -y supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /export
RUN echo "/docker /export/docker   none    bind  0  0" >> /etc/fstab

EXPOSE 111/udp 2049/tcp

#RUN sed -i 's/^RPCMOUNTDOPTS=.*/RPCMOUNTDOPTS="--manage-gids --port 2233"/' /etc/default/nfs-kernel-server

ADD supervisor/* /etc/supervisord.d/
CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
