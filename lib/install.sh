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

function ensure_default_settings_writable() {
    # Set write permissions to default dir, to be able to alter it here
    chmod u+w "$(projectdir)/www/web/sites/default"
    chmod u+w "$(projectdir)/www/web/sites/default/settings.php"
}

# No init === no composer.json
if [ ! -f "$(wwwdir)/composer.json" ]; then
    echo -e "\033[1;31m[ERROR]\033[0m Please execute \033[1mdrucker init\033[0m before."
    exit 1
fi

# docker-compose build
./docker-compose-utils.sh action="build" || exit 1    # @TOFIX: temporary "exit 1" because set-e is disabled

# docker build custom images
echo "Building custom images..."
docker build -t "${NODE_IMAGE}" "${NODE_CONTEXT}"

# Install vendor
echo "Installing dependencies..."
composer install

# Run drupal-scaffold
echo "Running Drupal-scaffold..."
composer run-script drupal-scaffold

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

ensure_default_settings_writable

# Install Drupal
if [ -e "$(projectdir)/www/config/sync/system.site.yml" ]; then

    isConfigInstallerInstalled=`composer show -N | grep "drupal/config_installer"`

    if [ -z "${isConfigInstallerInstalled}" ]; then
        echo -e "\033[1;33m[WARNING]\033[0m config_installer is not installed! Adding it to your dev dependencies..."
        warnings+=("The module config_installer was not installed, so it's now added to your dev dependencies.")
        composer require --dev drupal/config_installer
    fi

    # Install from config
    echo "Installing Drupal with config_installer (from config files)..."
    drush si config_installer -y \
        config_installer_sync_configure_form.sync_directory="../config/sync" \
        --db-url="mysql://${DB_DRUPAL_USER}:${DB_DRUPAL_PASSWORD}@$DB_DOMAIN/${DB_DRUPAL_DB}"  \
        --db-su=root \
        --db-su-pw="${DB_ROOT_PASSWORD}" \
        --site-name="${SITE_NAME}"  \
        --account-name="${ADMIN_USER}" \
        --account-pass="${ADMIN_PASSWORD}"

else
    # Fresh install
    echo "Installing Drupal (fresh install)..."
    drush si standard -y \
        --db-url="mysql://${DB_DRUPAL_USER}:${DB_DRUPAL_PASSWORD}@$DB_DOMAIN/${DB_DRUPAL_DB}"  \
        --db-su=root \
        --db-su-pw="${DB_ROOT_PASSWORD}" \
        --site-name="${SITE_NAME}"  \
        --account-name="${ADMIN_USER}" \
        --account-pass="${ADMIN_PASSWORD}"

    # First install, export the config
    echo "Exporting config from fresh install..."
    drush cex -y
fi

ensure_default_settings_writable

# Create settings.local.php
if [ ! -e "$(projectdir)/www/web/sites/default/settings.local.php" ]; then
    echo "Creating settings.local.php..."

    # Activates it inside settings.php
    echo "if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {" >> "$(projectdir)/www/web/sites/default/settings.php"
    echo "  include \$app_root . '/' . \$site_path . '/settings.local.php';" >> "$(projectdir)/www/web/sites/default/settings.php"
    echo "}" >> "$(projectdir)/www/web/sites/default/settings.php"

    # Append some local config
    cat << EOF >> "$(projectdir)/www/web/sites/default/settings.local.php"
<?php

\$settings['file_private_path'] = '../private/default/files';
\$config['system.file']['path.temporary'] = '../tmp';

// Debug mode
\$config['system.logging']['error_level'] = 'all';
\$config['system.performance']['css']['preprocess'] = false;
\$config['system.performance']['js']['preprocess'] = false;
\$config['views.settings']['ui']['show']['performance_statistics'] = true;
\$config['views.settings']['ui']['show']['sql_query']['enabled'] = true;

EOF

fi

# Create services.yml
if [ ! -e "$(projectdir)/www/web/sites/default/services.yml" ] && [ -e "$(projectdir)/www/web/sites/default/default.services.yml" ]; then
    echo "Creating services.yml..."
    cp "$(projectdir)/www/web/sites/default/default.services.yml" "$(projectdir)/www/web/sites/default/services.yml"
    # Activates debug mode
    sed -i 's/debug: false/debug: true/g' "$(projectdir)/www/web/sites/default/services.yml"
fi


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
