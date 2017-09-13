#!/usr/bin/env bash
#
# Initialize a Drupal environment, using composer

# set -e    @TOFIX: disabled due to "129" errcode from docker

pushd "$(pwd)" > /dev/null

# Main directories
DRUCKER_DIR="$(dirname $(dirname `readlink -f -- "$0"`))"    # druckerdir: father of this folder
PROJECT_DIR="$(dirname "${DRUCKER_DIR}")"                    # projectdir: grand-father of this folder

cd "${DRUCKER_DIR}/lib"

# load basic functions and project environment
. functions

# Remove existing Drupal, if present
if [ ! $(find "$(docroot)" -prune -empty) ]; then
    echo "*************************************************************************************"
    echo This will remove existing files from $(docroot) and download a new Drupal ${DRUPAL_VERSION} instance.
    echo "*************************************************************************************"
    echo "Do you want to continue? (y/n) "
    while true; do
        read yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

# docker-compose build
./docker-compose-utils.sh action="build" || exit 1    # @TOFIX: temporary "exit 1" because set-e is disabled

# Download Drupal into a temporary location
echo "Downloading and installing Drupal ${DRUPAL_VERSION} with Composer..."

# Temporary folder for the installation
web_tmp_drupal_dir="$(web_tmp)/drupal-${DRUPAL_VERSION}"
tmp_drupal_dir="$(tmp)/drupal-${DRUPAL_VERSION}"

# Remove it if exists
rm -rf "${tmp_drupal_dir}" 2> /dev/null

# Run installation
composer create-project \
    drupal-composer/drupal-project:${DRUPAL_VERSION}.x-dev \
    "${web_tmp_drupal_dir}" \
    --stability dev \
    --no-interaction \
    --no-install

# Move all the installation from tmp to the right dir
rsync -a "${tmp_drupal_dir}/" "$(wwwdir)/"

# Remove tmp dir
rm -rf "${tmp_drupal_dir}" 2> /dev/null

# configure .gitignore
cp -f "$(druckerdir)/templates/gitignore" "$(projectdir)/.gitignore"

# Greetings
printf "\033[0;32m\e[1m[DONE]\e[0m Your Drupal \e[1m${PROJECT_NAME}\e[0m is ready. You must now run \e[1mmake install\e[0m to configure it.\n"

popd > /dev/null
