FROM wodby/drupal-mariadb:1.0.0
MAINTAINER OVH-UX <github@ovh.net>

ARG DOCKER_USER=1000
ARG DOCKER_USER_GROUP=1001

# Override permissions with user/group of the host
RUN echo http://dl.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk --no-cache add shadow && usermod -u $DOCKER_USER mysql && groupmod -g $DOCKER_USER_GROUP mysql
RUN chown -R mysql:mysql /var/run/mysqld/

ENTRYPOINT ["docker-entrypoint.sh", "mysqld", "--user=mysql", "--console"]
