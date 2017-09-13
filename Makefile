
.PHONY: load-env

help:
	@echo "################################################################################"
	@echo " Drucker - DRUpal doCKER dev environment"
	@echo "--------------------------------------------------------------------------------"
	@echo " Available commands:"
	@echo "   - init                : Perform a fresh install of Drupal"
	@echo "   - install             : Launch the installation of all dependencies"
	@echo "   - start               : Launch the stack"
	@echo "   - stop                : Stop the stack"
	@echo "   - logs                : Show all the logs in real time"
	@echo "   - load-env            : Load all utilities in current env"
	@echo "   - gen-config          : Generate a new Drucker config file"
	@echo "   - backup              : Create a backup of the whole site (db and files)"
	@echo "   - restore             : Restore the whole site (db and files)"
	@echo "   - sql-backup-restore  : Create a backup and a restore of a database"
	@echo "   - sql-backup          : Create a backup of a database"
	@echo "   - sql-restore         : Restore a database"
	@echo "   - sql-sanitize        : Sanitize the current database"
	@echo "################################################################################"

init:
	@./lib/init.sh

install:
	@./lib/install.sh

start:
	@./lib/docker-compose-utils.sh action="start" -d

stop:
	@./lib/docker-compose-utils.sh action="stop"

logs:
	@./lib/docker-compose-utils.sh action="logs"

load-env:
	@echo "Please run 'source load-env' to load the environment."

gen-config:
	@./lib/gen-config.sh

dev:
	@echo "You can use:"
	@echo "  - make start|stop  : Start/stop containers"
	@echo "  - . load-env       : Load environment tools"

backup:
	@echo "You can use:"
	@echo "  - drush archive-dump  : For a full backup (files and database)"
	@echo "  - make sql-backup     : For a backup of the database only"
restore:
	@echo "You can use:"
	@echo "  - drush archive-restore --overwrite /home/www-data/drush-backups/archive-dump/path/to/backup  : To restore a full backup (files and database)"
	@echo "  - make sql-restore   : To restore a backup of the database only"

sql-backup-restore:
	@./lib/sql-backup-restore.sh
sql-backup:
	@./lib/sql-backup-restore.sh --backup -y
sql-restore:
	@./lib/sql-backup-restore.sh --restore -y
sql-sanitize:
	@./lib/sql-backup-restore.sh --sanitize -y
