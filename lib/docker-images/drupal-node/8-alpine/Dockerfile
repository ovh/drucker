FROM node:8-alpine
MAINTAINER OVH-UX <github@ovh.net>

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
RUN apk update && apk --no-cache add shadow build-base make gcc g++ python git tini

RUN npm set progress=false && npm install -gq gulp-cli grunt-cli bower yo

# @see https://github.com/moby/moby/issues/2838#issuecomment-256174928
ENTRYPOINT ["/sbin/tini", "--"]
