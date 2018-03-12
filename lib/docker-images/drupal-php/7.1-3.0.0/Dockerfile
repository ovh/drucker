FROM wodby/drupal-php:7.1-3.0.0
MAINTAINER OVH-UX <github@ovh.net>

ARG DOCKER_USER=1000
ARG DOCKER_USER_GROUP=1001

# Switch to root
# @see https://github.com/wodby/php/commit/d4c0b703310471b3555a360e343f6d7551162d37
USER root

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk update && apk --no-cache add shadow

# Deactivate IPv6
## @see https://github.com/wodby/base-php/blob/master/7.1/fpm/Dockerfile
## @see https://github.com/wodby/php/blob/master/7.1/templates/zz-www.conf.tpl
RUN sed -i "s/^listen = \[::\]:9000$/listen = 0.0.0.0:9000/" /usr/local/etc/php-fpm.d/zz-docker.conf
RUN sed -i "s/^listen = \[::\]:9001$/listen = 0.0.0.0:9001/" /etc/gotpl/zz-www.conf.tpl

# Override permissions with user/group of the host
RUN usermod -u $DOCKER_USER www-data && groupmod -g $DOCKER_USER_GROUP www-data
## Change files with old uid/gid
RUN find / -group 82 -exec chgrp -h $DOCKER_USER_GROUP {} \; && find / -user 82 -exec chown -h $DOCKER_USER {} \;
## User www-data can su (for phproot)
RUN chmod u+s /sbin/su-exec

# Re-switch to www-data
# @see https://github.com/wodby/php/commit/d4c0b703310471b3555a360e343f6d7551162d37
USER www-data
