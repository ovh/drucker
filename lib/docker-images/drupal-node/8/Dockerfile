FROM node:8
MAINTAINER OVH-UX <github@ovh.net>

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential make gcc g++ python openssl git \
    && rm -rf /var/lib/apt/lists/*

RUN npm set progress=false && npm install -gq gulp-cli grunt-cli yo bower
