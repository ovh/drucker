FROM wodby/drupal-nginx:8-1.13
MAINTAINER OVH-UX <github@ovh.net>

ARG DOCKER_USER=1000
ARG DOCKER_USER_GROUP=1001

# Override permissions with user/group of the host
RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk --no-cache add shadow && usermod -u $DOCKER_USER www-data && groupmod -g $DOCKER_USER_GROUP www-data
