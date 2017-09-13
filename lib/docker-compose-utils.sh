#!/bin/bash
#
# Docker-compose utils

# set -e    @TOFIX: disabled due to "129" errcode from docker

ACTION=""
DETACHED=""

for key in "$@"
do
case $key in
    action=*)
    ACTION="${key#*=}"
    shift # past argument
    ;;
    -d)
    DETACHED="-d"
    shift # past argument
    ;;
    *)
    echo -e "\033[1;31m[ERROR]\033[0m You need to provide an action"
    exit 1
    ;;
esac
done

pushd "$(pwd)" > /dev/null

# Main directories
DRUCKER_DIR="$(dirname $(dirname `readlink -f -- "$0"`))"    # druckerdir: father of this folder
PROJECT_DIR="$(dirname "${DRUCKER_DIR}")"                    # projectdir: grand-father of this folder

cd "${DRUCKER_DIR}/lib"

# load functions and environment variables
. functions

popd > /dev/null

# Check if docker-compose is available
hash docker-compose 2>/dev/null || { echo >&2 -e "\033[1;31m[ERROR]\033[0m Please install docker-compose before."; exit 1; }

# give a name to the container of docker-compose (if run as Docker container)
export DOCKER_RUN_OPTIONS="--name=${PROJECT_NAME_PLAIN}_startup"

case "$ACTION" in
"build")
    echo -e "Build \033[1m$PROJECT_NAME\033[0m project..."
    docker-compose --project-name "$PROJECT_NAME_PLAIN" -f "$(druckerdir)/lib/docker-compose.yml" build --no-cache
    ;;
"up"|"start")
    echo -e "Start \033[1m$PROJECT_NAME\033[0m project"
    docker-compose --project-name "$PROJECT_NAME_PLAIN" -f "$(druckerdir)/lib/docker-compose.yml" up $DETACHED
    ;;
"down"|"stop")
    # Since docker-compose up is not in attached mode, correctly down the project when ctrl+c
    echo -e "Stop \033[1m$PROJECT_NAME\033[0m project"
    docker-compose --project-name "$PROJECT_NAME_PLAIN" -f "$(druckerdir)/lib/docker-compose.yml" down
    ;;
"logs")
    docker-compose --project-name "$PROJECT_NAME_PLAIN" -f "$(druckerdir)/lib/docker-compose.yml" logs -f
    ;;
*)
    echo >&2 -e "\033[1;31m[ERROR]\033[0m Unknown action"
    exit 1
esac
