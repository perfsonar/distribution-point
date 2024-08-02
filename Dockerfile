#
# Docker Dister Dockerfile
#

ARG FROM=alpine:latest
FROM ${FROM}


VOLUME /data


# TODO: Can remove curl and vim
RUN apk add \
    lighttpd \
    logrotate \
    openssl \
    rsync \
    rsyslog \
    supervisor


# Lighttpd
ADD etc/lighttpd.conf /etc


# Rsyncd
ADD etc/rsyncd.conf /etc


# Supervisord
ADD etc/supervisord.conf /etc
RUN mkdir -p /etc/supervisord.d
ADD etc/supervisord.d/* /etc/supervisord.d


ADD bin/* /usr/bin


# This must be the "exec" format; Debian doesn't handle shell-style
# properly.
ENTRYPOINT [ "/usr/bin/docker-entrypoint" ]
