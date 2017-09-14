#!/usr/bin/env bash
#
# Install all the deps

# set -e    @TOFIX: disabled due to "129" errcode from docker

warnings=()

pushd "$(pwd)" > /dev/null

# Main directories
DRUCKER_DIR="$(dirname $(dirname `readlink -f -- "$0"`))"    # druckerdir: father of this folder
PROJECT_DIR="$(dirname "${DRUCKER_DIR}")"                    # projectdir: grand-father of this folder

cd "${DRUCKER_DIR}/lib"

# load functions and environment variables
. functions

# No init === no composer.json
if [ ! -f "$(wwwdir)/composer.json" ]; then
    echo -e "\033[1;31m[ERROR]\033[0m Please execute \033[1mmake init\033[0m before."
    exit 1
fi

# docker-compose build
./docker-compose-utils.sh action="build" || exit 1    # @TOFIX: temporary "exit 1" because set-e is disabled

# docker build custom images
echo "Building custom images..."
docker build -t "${NODE_IMAGE}" "${NODE_CONTEXT}" --no-cache

# Install vendor
echo "Installing dependencies..."
composer install

# Install and build custom themes
echo "Building custom themes..."
./compile-themes.sh || warnings+=("Something goes wrong when compiling themes. Please try to compile them by yourself.")

# Start the stack, to perform some configurations
./docker-compose-utils.sh action="start" -d

# Wait for Database created
echo -n "Waiting for the database connection..."
while true; do

    # @TOFIX: maybe we can find a better solution
    dbready=`(docker-compose \
        --project-name "$PROJECT_NAME_PLAIN" \
        -f "$(druckerdir)/lib/docker-compose.yml" \
        exec -T $DB_SERVICE mysql -u"${DB_DRUPAL_USER}" -p"${DB_DRUPAL_PASSWORD}" --execute="SHOW DATABASES LIKE '${DB_DRUPAL_DB}'")`

    # @TOFIX: set+e here when we fix the set-e issue
    if [ "$?" != 0 ] || [ -z "$(echo -e '${dbready}' | tr -d '[:space:]')" ]; then
        echo -n "."
        sleep 2
    else
        echo "Done!"
        break;
    fi
done

# Install Drupal
echo "Installing Drupal..."
drush si standard -y \
    --db-url="mysql://${DB_DRUPAL_USER}:${DB_DRUPAL_PASSWORD}@$DB_DOMAIN/${DB_DRUPAL_DB}"  \
    --db-su=root \
    --db-su-pw="${DB_ROOT_PASSWORD}" \
    --site-name="${SITE_NAME}"  \
    --account-name="${ADMIN_USER}" \
    --account-pass="${ADMIN_PASSWORD}"

# Config import/export
if [ -e "$(projectdir)/www/config/sync/system.site.yml" ]; then
    echo "Importing existing config..."
    SITE_UUID=`grep -r "uuid" "$(projectdir)/www/config/sync/system.site.yml" | awk '{print $2}'`
    # @FIXME: see https://www.dannyenglander.com/blog/drupal-8-development-how-import-existing-site-configuration-new-site
    drush ev '\Drupal::entityManager()->getStorage("shortcut_set")->load("default")->delete();'
    drush cset system.site uuid "${SITE_UUID}" -y
    drush cim -y
else
    # First install, export the config
    echo "Exporting config from fresh install..."
    drush cex -y
fi

# @TODO: later!
#cd "$(docroot)"
# make some folders
#folders="modules/contrib themes/contrib profiles/contrib modules/custom modules/features themes/custom"
#for i in ${folders}; do
#  mkdir ${i} 2> /dev/null
#done
# prepare settings.php
#if [ "${DRUPAL_VERSION}" = "7" ]; then
#    cat << EOF >> sites/default/settings.php
#\$conf['file_private_path'] = '../private/default/files';
#\$conf['file_temporary_path'] = '../tmp';
#EOF
#else
#    cat << EOF >> sites/default/settings.php
#\$settings['file_private_path'] = '../private/default/files';
#\$config['system.file']['path.temporary'] = '../tmp';
#\$config_directories['sync'] = '../config/default/sync';
#if (file_exists(__DIR__ . '/settings.local.php')) {
#  include __DIR__ . '/settings.local.php';
#}
#EOF
#fi

# Install Git hooks
while true; do
    echo -ne "\033[1mDo you want to install Git hooks?\033[0m (y/n): "
    read yn
    case $yn in
        [Yy]* )
            # relative path because we don't want to break link when mounted in different env
            gitkooks_relativepath=`realpath --relative-to="$(projectdir)/.git/hooks" "$(druckerdir)/githooks"`
            ln -s "${gitkooks_relativepath}/post-checkout" -t "$(projectdir)/.git/hooks" -f
            ln -s "${gitkooks_relativepath}/post-merge" -t "$(projectdir)/.git/hooks" -f
            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Warnings
if [ ! ${#warnings[@]} -eq 0 ]; then
    for warning in "${warnings[@]}"
    do
        echo -e "\033[1;33m[WARNING]\033[0m ${warning}"
    done
fi

# Greetings
printf "\033[0;32m\e[1m[DONE]\e[0m Your Drupal \e[1m${PROJECT_NAME}\e[0m is ready.\n"

popd > /dev/null
