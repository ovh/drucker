#!/bin/bash

# set -e    @TOFIX: disabled due to "129" errcode from docker

DUMP=false
RESTORE=false
SANITIZE=false
DUMP_RUN=false
RESTORE_RUN=false
SANITIZE_RUN=false
YES=false

DUMP_DBNAME=""
DUMP_DBNAME_ESCAPED=""
RESTORE_DBNAME=""
RESTORE_DBNAME_ESCAPED=""

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "sql-backup-restore - Dump / Restore a database"
            echo " "
            echo "sql-backup-restore [options]"
            echo " "
            echo "options:"
            echo "-h, --help              show brief help"
            echo "--backup                (optional) backup database"
            echo "--backup=NAME           (optional) backup database, with given name"
            echo "--restore               (optional) restore database"
            echo "--restore=NAME          (optional) restore database, with given name"
            echo "--sanitize              (optional) sanitize current database"
            echo "-y, --yes               (optional) assume yes"
            exit 0
            ;;
        --backup|--dump)
            DUMP=true
            shift
            ;;
        --restore)
            RESTORE=true
            shift
            ;;
        --backup*|--dump*)
            DUMP=true
            export DUMP_DBNAME=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        --restore*)
            RESTORE=true
            export RESTORE_DBNAME=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        --sanitize)
            SANITIZE=true
            shift
            ;;
        -y|--yes)
            YES=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ "${DUMP}" = false ] && [ "${RESTORE}" = false ]; then
    DUMP=true
    RESTORE=true
fi

pushd "$(pwd)" > /dev/null

# Main directories
DRUCKER_DIR="$(dirname $(dirname `readlink -f -- "$0"`))"    # druckerdir: father of this folder
PROJECT_DIR="$(dirname "${DRUCKER_DIR}")"                    # projectdir: grand-father of this folder

cd "${DRUCKER_DIR}/lib"

# load functions and environment variables
. functions

pathToSqlDirLocal="$(druckerdir)/docker-runtime/sql-backups"
pathToSqlDirRemote="/home/www-data/sql-backups"

mkdir -p "${pathToSqlDirLocal}"

popd > /dev/null

function escapeDbName () {
    sed -e 's/\//___/g' | sed -e 's/^\.//g'
}

function unescapeDbName () {
    sed -e 's/___/\//g'
}

function listDatabases ()
{
    echo -e "\033[1mAvailable databases:\033[0m"
    ls -A1 "${pathToSqlDirLocal}" | sed -e 's/\.sql//g' | sed -e 's/^/  - /g' | unescapeDbName
}

function clearCache () {
    echo "Clear cache..."
    drush cr
}

function backupDatabase ()
{
    # set db name if not given
    if [ -z "${DUMP_DBNAME}" ]; then
        while true; do
            read -p "What is the name of the database? " DUMP_DBNAME
            if [ ! -z "${DUMP_DBNAME}" ]; then
                break;
            fi
        done
    fi

    DUMP_DBNAME_ESCAPED=$(echo "${DUMP_DBNAME}" | escapeDbName)

    echo "Clear database..."
    clearCache
    echo "Backuping ${DUMP_DBNAME}..."
    drush sql-dump --result-file="${pathToSqlDirRemote}/${DUMP_DBNAME_ESCAPED}.sql"
    echo -e "\033[0;32m\e[1m[DONE]\e[0m Backup available here: ${pathToSqlDirLocal}/${DUMP_DBNAME_ESCAPED}.sql"
}

function restoreDatabase ()
{
    if [ ! -z "${RESTORE_DBNAME}" ] && [ ! -f "${pathToSqlDirLocal}/$(echo ${RESTORE_DBNAME} | escapeDbName).sql" ]; then
        echo "This database doesn't exist!"
        RESTORE_DBNAME=""
    fi

    RESTORE_DBNAME_SUGGESTED=""
    if [ ! -z "${RESTORE_DBNAME}" ]; then
        RESTORE_DBNAME_SUGGESTED="${RESTORE_DBNAME}"
    elif [ -f "${pathToSqlDirLocal}/develop.sql" ]; then
        RESTORE_DBNAME_SUGGESTED="develop"
    elif [ -f "${pathToSqlDirLocal}/master.sql" ]; then
        RESTORE_DBNAME_SUGGESTED="master"
    fi

    while true; do

        if [ "${YES}" = true ] && [ ! -z "${RESTORE_DBNAME}" ]; then
            echo -e "\033[1mWhich database you want to restore ([l] to list)?\033[0m ${RESTORE_DBNAME}"
        else
            if [ -z "${RESTORE_DBNAME_SUGGESTED}" ]; then
                echo -ne "\033[1mWhich database you want to restore ([l] to list)?\033[0m "
            else
                echo -ne "\033[1mWhich database you want to restore ([l] to list)?\033[0m (${RESTORE_DBNAME_SUGGESTED}): "
            fi
            read -p "" RESTORE_DBNAME
        fi

        if [ "${RESTORE_DBNAME}" == "l" ]; then
            listDatabases
            RESTORE_DBNAME=""
            continue;
        fi

        if [ -z "${RESTORE_DBNAME}" ]; then
            if [ ! -z "${RESTORE_DBNAME_SUGGESTED}" ]; then
                RESTORE_DBNAME="${RESTORE_DBNAME_SUGGESTED}"
            else
                echo "Please provide a database name"
                continue;
            fi
        fi

        RESTORE_DBNAME_ESCAPED=$(echo ${RESTORE_DBNAME} | escapeDbName)

        if [ ! -f "${pathToSqlDirLocal}/${RESTORE_DBNAME_ESCAPED}.sql" ]; then
            echo "This database doesn't exist!"
            RESTORE_DBNAME=""
            continue;
        fi

        break;
    done

    echo "Drop current database..."
    drush sql-drop -y
    echo "Restore database ${RESTORE_DBNAME}..."
    phproot "cd web && drush sql-cli < ${pathToSqlDirRemote}/${RESTORE_DBNAME_ESCAPED}.sql"      # @TOFIX: not clean
    echo "Clear database..."
    clearCache
    echo -e "\033[0;32m\e[1m[DONE]\e[0m Database ${RESTORE_DBNAME} restored."
}

function sanitizeDatabase () {
    echo "Sanitize current database..."
    drush sql-sanitize -y --sanitize-password="${ADMIN_PASSWORD}" --sanitize-email
    echo -e "\033[0;32m\e[1m[DONE]\e[0m Database sanitized."
}

###############################################################################

# allows us to read user input below, assigns stdin to keyboard
exec < /dev/tty

####### dump #######

if [ "${DUMP}" = true ]; then
    if [ "${YES}" = true ]; then
        echo -e "\033[1mDo you want to backup the database?\033[0m (Y/n): yes"
        DUMP_RUN=true
    else
        while true; do
            echo -ne "\033[1mDo you want to backup the database?\033[0m (Y/n): "
            read -p "" action

            if [ -z "${action}" ] || [ "${action}" == "y" ] || [ "${action}" == "Y" ] || [ "${action}" == "yes" ]; then
                # Yes
                DUMP_RUN=true
                break;
            elif [ "${action}" == "n" ] || [ "${action}" == "N" ] || [ "${action}" == "no" ]; then
                # No
                break;
            fi
        done
    fi
fi

if [ "${DUMP_RUN}" = true ]; then
    backupDatabase
fi

###### restore ######

if [ "${RESTORE}" = true ]; then
    if [ "${YES}" = true ]; then
        echo -e "\033[1mDo you want to restore a database??\033[0m (Y/n): yes"
        RESTORE_RUN=true
    else
        while true; do
            echo -e "\033[1mDo you want to restore a database?\033[0m"
            echo "  [y] Yes (default)"
            echo "  [l] List available databases"
            echo "  [n] No"
            read -p "Select an action (Y/n/l): " action

            if [ -z "${action}" ] || [ "${action}" == "y" ] || [ "${action}" == "Y" ] || [ "${action}" == "yes" ]; then
                # Yes
                RESTORE_RUN=true
                break;
            elif [ "${action}" == "n" ] || [ "${action}" == "N" ] || [ "${action}" == "no" ]; then
                # No
                break;
            elif [ "${action}" == "l" ] || [ "${action}" == "list" ]; then
                # List
                listDatabases
            else
                echo "Please select an action."
            fi
        done
    fi
fi

if [ "${RESTORE_RUN}" = true ]; then
    restoreDatabase
fi

####### sanitize #######

if [ "${SANITIZE}" = true ]; then
    if [ "${YES}" = true ]; then
        echo -e "\033[1mDo you want to sanitize the current database?\033[0m (Y/n): yes"
        SANITIZE_RUN=true
    else
        while true; do
            echo -ne "\033[1mDo you want to sanitize the current database?\033[0m (Y/n): "
            read -p "" action

            if [ -z "${action}" ] || [ "${action}" == "y" ] || [ "${action}" == "Y" ] || [ "${action}" == "yes" ]; then
                # Yes
                SANITIZE_RUN=true
                break;
            elif [ "${action}" == "n" ] || [ "${action}" == "N" ] || [ "${action}" == "no" ]; then
                # No
                break;
            fi
        done
    fi
fi

if [ "${SANITIZE_RUN}" = true ]; then
    sanitizeDatabase
fi
