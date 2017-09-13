## Prerecquisites

You need to source the `load-env` file inside Drucker directory to access all these tools:
```bash
$ cd drucker
$ . load-env
```

---

## PHP CLI

You can use the PHP CLI directly in your environment.
```bash
$ php [options] [-f] <file> [args...]
```

Note: if you just enter `php`, it'll launch a prompt inside the PHP container.

---

## Drush

PHP container has Drush installed.
```bash
$ drush
```

Also, you can use preconfigured drush alias @dev:
```bash
$ drush @dev
```

!!! note ""
    Launch `drush init` to add some additional useful features, like Drush auto-completion.

**Useful commands:**

- `drush cr` : Clear the cache
- `drush cim` : Import the configuration to your current database
- `drush cex` : Export your current configuration to config files
- `drush sql-connect` : Open a SQL CLI

You can find all documentation [here](https://drushcommands.com).

---

## Composer

PHP container has Composer installed.
```bash
$ composer
```

**Useful commands:**

- `composer install` : Install all dependencies, using composer.json
- `composer update` : Update all dependencies
- `composer require drupal/<module>` : Install a module from Drupal hub

You can find all documentation [here](https://getcomposer.org/doc/03-cli.md).

---

## Drupal Console

PHP container has Drupal Console launcher installed. Drupal Console itself must be installed per project manually via Composer.
```bash
$ drupal
```

The Drupal Console is useful for the `generate` feature. It can generates a bunch of useful things.
You can, for example, generate a module, using this command:
```bash
$ drupal generate:module
```

!!! note ""
    Launch `drupal init` to add some additional useful features, like Drupal Console auto-completion.

**Useful commands:**

- `drupal list` : List all available commands

You can find all documentation [here](https://hechoendrupal.gitbooks.io/drupal-console/content/en/index.html).

---

## Node.js

You have access to a Node.js container.
```bash
$ node [options] [v8 options] [script.js | -e "script" | -] [--] [arguments]
```

Note: the current folder is mounted inside `/usr/src/app`, and it's the working dir.

---

## NPM/Yarn/Gulp

You can use one of these tools, that will be launched inside the Node.js container.
```bash
$ npm
[or]
$ yarn
[or]
$ gulp
```

Note: the current folder is mounted inside `/usr/src/app`, and it's the working dir.

---
