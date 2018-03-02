FROM wodby/mariadb:10.1-3.0.0
MAINTAINER OVH-UX <github@ovh.net>

ARG DOCKER_USER=1000
ARG DOCKER_USER_GROUP=1001

USER root
RUN apk update && apk --no-cache add shadow

# Override permissions with user/group of the host
RUN usermod -u $DOCKER_USER mysql && groupmod -g $DOCKER_USER_GROUP mysql
RUN chown -R mysql:mysql /var/run/mysqld/
## Change files with old uid/gid
RUN find / -group 101 -exec chgrp -h $DOCKER_USER_GROUP {} \; && find / -user 100 -exec chown -h $DOCKER_USER {} \;

USER mysql

ENTRYPOINT ["/docker-entrypoint.sh", "mysqld", "--user=mysql", "--console"]
