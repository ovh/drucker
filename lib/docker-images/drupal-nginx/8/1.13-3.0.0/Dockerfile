FROM wodby/drupal-nginx:8-1.13-3.0.0
MAINTAINER OVH-UX <github@ovh.net>

ARG DOCKER_USER=1000
ARG DOCKER_USER_GROUP=1001

# Switch to root
# @see https://github.com/wodby/php/commit/d4c0b703310471b3555a360e343f6d7551162d37
USER root

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk update && apk --no-cache add shadow

# Override permissions with user/group of the host
RUN usermod -u $DOCKER_USER www-data && groupmod -g $DOCKER_USER_GROUP www-data
## Change files with old uid/gid
RUN find / -group 82 -exec chgrp -h $DOCKER_USER_GROUP {} \; && find / -user 82 -exec chown -h $DOCKER_USER {} \;

# Re-switch to www-data
# @see https://github.com/wodby/php/commit/d4c0b703310471b3555a360e343f6d7551162d37
USER www-data
