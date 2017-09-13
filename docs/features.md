## Logs

You can access all the containers logs, using these commands:
```bash
$ cd drucker
$ make logs
```

!!! note ""
    You can also check all Drupal logs, inside the admin page `/admin/reports/dblog`.

---

## Backup - Full

You can create a snapshot of all your Drupal at anytime (files and database), using this command:
```bash
$ drush archive-dump
```
This command will create a `tar.gz` file, that will be stored inside `drucker/docker-runtime/drush-backups`.

To restore the full backup, you can use this command:
```bash
$ drush archive-restore --overwrite /home/www-data/drush-backups/archive-dump/path/to/backup
```
Replace the `path/to/backup` by the path of the archive contained inside `drucker/docker-runtime/drush-backups`.

!!! danger ""
    This command will overwrite all your current files and database!

---

## Backup - SQL Database only

You can create a backup of the SQL database only (so, without files), using these commands:
```bash
$ cd drucker
$ make sql-backup
# prompt: enter the name of the backup
```
The backup will be stored inside `drucker/docker-runtime/sql-backups`.

You can then restore a backup using these commands:
```bash
$ cd drucker
$ make sql-restore
# prompt: enter the name of the backup to restore
```

!!! note ""
    - You can type `l` to list all the available backups.
    - When the backup is restored, you'll be invited to sanitize the database (recommanded).

---

## SQL Sanitize

You can sanitize the current database, using these commands:
```bash
$ cd drucker
$ make sql-sanitize
```

This will reset all password accounts and emails.

---

## Accessing containers

You can access PHP containers, using the shortcuts:

- `php`: to run a shell inside the PHP container, as current user
- `phproot`: to run a shell inside the PHP container, as root user (use it with caution!)

---

## Multiple projects

You can launch and manage many Drucker instances at the same time. This is usefull when you work on multiple website in parrallel.

For example, if you have 2 projects in 2 differents folders, you can open **2** separated bash, and source the env of each project separately.

To make it works, you need to set differents values inside the `drucker.config` of your projects:

  - `PROJECT_NAME` and `PROJECT_NAME_PLAIN` must have different values for each projects
  - `PUBLIC_WWW_PORT` and `PUBLIC_PMA_PORT` must have different ports for each projects
  - `SUBNET` must have different values for each projects: just change the 3rd octet of IP-addresses

Example:

  - **project1**:
    - `PROJECT_NAME=Project1` and `PROJECT_NAME_PLAIN=project1`
    - `PUBLIC_WWW_PORT=19580` and `PUBLIC_PMA_PORT=19581`
    - `SUBNET=172.16.1`
    - You can open a *separated* bash and run `cd <project1>; cd drucker; source load-env; make start`.
    - -> your website will be accessible with the URL: `http://localhost:19580` (and `http://localhost:19581`)
  - **project2**:
    - `PROJECT_NAME=Project2` and `PROJECT_NAME_PLAIN=project2`
    - `PUBLIC_WWW_PORT=19590` and `PUBLIC_PMA_PORT=19591`
    - `SUBNET=172.16.2`
    - You can open a *separated* bash and run `cd <project2>; cd drucker; source load-env; make start`.
    - -> your website will be accessible with the URL: `http://localhost:19590` (and `http://localhost:19591`)

---

## Modules patches

You can apply patches, using Composer: [read this](https://github.com/drupal-composer/drupal-project#how-can-i-apply-patches-to-downloaded-modules).

---
