#!/usr/bin/env bash
#
# Generate a new Drucker config file

set -e

pushd "$(pwd)" > /dev/null

# Main directories
DRUCKER_DIR="$(dirname $(dirname `readlink -f -- "$0"`))"    # druckerdir: father of this folder
PROJECT_DIR="$(dirname "${DRUCKER_DIR}")"                    # projectdir: grand-father of this folder

cd "${DRUCKER_DIR}/lib"

## PROJECT_NAME
while true; do
  printf "\e[1mEnter the name of the project:\e[0m "
  read PROJECT_NAME

  REGEX='^[a-z0-9_.-]+$';
  if ! [[ $PROJECT_NAME =~ $REGEX ]]; then
      echo "Invalid input. Please use letters, numbers, dashes, dots, underscores, no whitespace."
  else
      break;
  fi
done

## PROJECT_NAME_PLAIN
# Trim and escape PROJECT_NAME
PROJECT_NAME_PLAIN_DEFAULT=`echo ${PROJECT_NAME} | tr '[:upper:]' '[:lower:]' | sed -e 's/[_.-]//g'`
while true; do
  printf "\e[1mEnter the plain name of the project:\e[0m (${PROJECT_NAME_PLAIN_DEFAULT}) "
  read PROJECT_NAME_PLAIN

  if [ -z $PROJECT_NAME_PLAIN ]; then
    PROJECT_NAME_PLAIN=$PROJECT_NAME_PLAIN_DEFAULT
  fi

  REGEX='^[a-z0-9]+$';
  if ! [[ $PROJECT_NAME_PLAIN =~ $REGEX ]]; then
      echo "Invalid input. Please use only lower letters and numbers."
  else
      break;
  fi
done

## PUBLIC_WWW_PORT
while true; do
  printf "\e[1mEnter the www port:\e[0m (80) "
  read PUBLIC_WWW_PORT

  if [ -z $PUBLIC_WWW_PORT ]; then
    PUBLIC_WWW_PORT=80
  fi

  REGEX='^[0-9]+$';
  if ! [[ $PUBLIC_WWW_PORT =~ $REGEX ]]; then
      echo "Invalid input. Please use only numbers."
  else
      break;
  fi
done

## PUBLIC_PMA_PORT
while true; do
  printf "\e[1mEnter the phpMyAdmin port:\e[0m (80) "
  read PUBLIC_PMA_PORT

  if [ -z $PUBLIC_PMA_PORT ]; then
    PUBLIC_PMA_PORT=80
  fi

  REGEX='^[0-9]+$';
  if ! [[ $PUBLIC_PMA_PORT =~ $REGEX ]]; then
      echo "Invalid input. Please use only numbers."
  else
      break;
  fi
done

## SUBNET
while true; do
  printf "\e[1mEnter the network subnet:\e[0m (172.16.1) "
  read SUBNET

  if [ -z $SUBNET ]; then
    SUBNET="172.16.1"
  fi

  REGEX='^[0-9]+\.[0-9]+\.[0-9]+$';
  if ! [[ $SUBNET =~ $REGEX ]]; then
      echo "Invalid input. Please use a right subnet (like '172.16.1')."
  else
      break;
  fi
done

## DRUPAL_VERSION
while true; do
  printf "\e[1mEnter the Drupal version:\e[0m (8) "
  read DRUPAL_VERSION

  if [ -z $DRUPAL_VERSION ]; then
    DRUPAL_VERSION=8
  fi

  # @TOFIX: only Drupal 8 for now
  # REGEX='^7|8$';
  REGEX='^8$';
  if ! [[ $DRUPAL_VERSION =~ $REGEX ]]; then
      echo "Invalid input. Please use only numbers."
  else
      break;
  fi
done

## PHP_VERSION
while true; do
  printf "\e[1mEnter the PHP version:\e[0m (7.0) "
  read PHP_VERSION

  if [ -z $PHP_VERSION ]; then
    PHP_VERSION="7.0"
  fi

  # @TOFIX: only PHP 7.0-1 for now
  # REGEX='^[0-9]+(\.[0-9]+)?$';
  REGEX='^7\.[0-1]$';
  if ! [[ $PHP_VERSION =~ $REGEX ]]; then
      echo "Invalid input. Please use only numbers."
  else
      break;
  fi
done

## PHP_XDEBUG_ENABLED
while true; do
  printf "\e[1mDo you want to enable XDEBUG?\e[0m (no) "
  read PHP_XDEBUG_ENABLED

  if [ -z $PHP_XDEBUG_ENABLED ]; then
    PHP_XDEBUG_ENABLED="no"
  fi

  REGEX='^(yes)|(no)$';
  if ! [[ $PHP_XDEBUG_ENABLED =~ $REGEX ]]; then
      echo "Invalid input. Please answer yes or no."
  else
      if [ $PHP_XDEBUG_ENABLED = "yes" ]; then
        PHP_XDEBUG_ENABLED=1
      else
        PHP_XDEBUG_ENABLED=0
      fi
      break;
  fi
done

# Additional XDEBUG variables
PHP_XDEBUG_REMOTE_HOST="localhost"
PHP_XDEBUG_REMOTE_PORT="9000"
if [ "${PHP_XDEBUG_ENABLED}" == 1 ]; then

  ## PHP_XDEBUG_REMOTE_HOST
  while true; do
    printf "\e[1mEnter the XDEBUG remote host:\e[0m "
    read PHP_XDEBUG_REMOTE_HOST

    REGEX='^[a-z0-9_.-]+$';
    if ! [[ $PHP_XDEBUG_REMOTE_HOST =~ $REGEX ]]; then
        echo "Invalid input. Please use a valid host name."
    else
        break;
    fi
  done

  ## PHP_XDEBUG_REMOTE_PORT
  while true; do
    printf "\e[1mEnter the XDEBUG remote port:\e[0m "
    read PHP_XDEBUG_REMOTE_PORT

    REGEX='^[0-9]+$';
    if ! [[ $PHP_XDEBUG_REMOTE_PORT =~ $REGEX ]]; then
        echo "Invalid input. Please use only numbers."
    else
        break;
    fi
  done
fi

## NODE_VERSION
while true; do
  printf "\e[1mEnter the Node.js version:\e[0m (9-alpine) "
  read NODE_VERSION

  if [ -z $NODE_VERSION ]; then
    NODE_VERSION="9-alpine"
  fi

  REGEX='^[89]((-alpine)|(-php))?$';
  if ! [[ $NODE_VERSION =~ $REGEX ]]; then
      echo "Invalid input. Please use valid version."
  else
      break;
  fi
done

## NODE_BROWSERSYNC_PORT
if [ "${NODE_VERSION}" == "9-php" ]; then
  while true; do
    printf "\e[1mEnter the Browser-Sync port (exposed from NodeJS container):\e[0m (3050) "
    read NODE_BROWSERSYNC_PORT

    if [ -z $NODE_BROWSERSYNC_PORT ]; then
      NODE_BROWSERSYNC_PORT=3050
    fi

    REGEX='^[0-9]+(\-[0-9]+)?$';
    if ! [[ $NODE_BROWSERSYNC_PORT =~ $REGEX ]]; then
        echo "Invalid input. Please use only numbers or a range."
    else
        break;
    fi
  done
fi

# ---

cp -f "${DRUCKER_DIR}/templates/drucker.config" "${PROJECT_DIR}/drucker.config"

sed -i "s/%%PROJECT_NAME%%/$PROJECT_NAME/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PROJECT_NAME_PLAIN%%/$PROJECT_NAME_PLAIN/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PUBLIC_WWW_PORT%%/$PUBLIC_WWW_PORT/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PUBLIC_PMA_PORT%%/$PUBLIC_PMA_PORT/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%DRUPAL_VERSION%%/$DRUPAL_VERSION/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PHP_VERSION%%/$PHP_VERSION/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PHP_XDEBUG_ENABLED%%/$PHP_XDEBUG_ENABLED/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PHP_XDEBUG_REMOTE_HOST%%/$PHP_XDEBUG_REMOTE_HOST/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%PHP_XDEBUG_REMOTE_PORT%%/$PHP_XDEBUG_REMOTE_PORT/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%SUBNET%%/$SUBNET/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%NODE_VERSION%%/$NODE_VERSION/g" "${PROJECT_DIR}/drucker.config"
sed -i "s/%%NODE_BROWSERSYNC_PORT%%/$NODE_BROWSERSYNC_PORT/g" "${PROJECT_DIR}/drucker.config"

# Greetings
printf "\033[0;32m\e[1m[DONE]\e[0m Your drucker.config file is created.\n"

popd > /dev/null
