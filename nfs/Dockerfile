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

RUN echo "/docker /export/docker   none    bind  0  0" >> /etc/fstab
