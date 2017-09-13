Drucker - DRUpal doCKER dev environment
=======================================

![drucker](banner.png)

Drucker is a lightweight Drupal developer environment. It contains required tools, like Drush or Composer, without useless extra.
The goals of this project is to have a Drupal development environment without installing anything on your desk (except Docker), and to be easy as possible to use.

You don't need any services installed (like PHP, MySQL, ...) or any WAMP/LAMP/... stack. Everything is managed by Docker, with the following containers:

* A container with Nginx
* A container with PHP, Drush, Drupal Console, Composer
* A container with phpMyAdmin
* A container with Mariadb
* A container with Mailhog
* Node.js, NPM, Yarn and Gulp on the fly

If you want a more advanced stack, take a look at [Docker4Drupal](https://github.com/wodby/docker4drupal) or [Drupal VM](https://github.com/geerlingguy/drupal-vm) projects.


## Prerequisites

An environnement where you can have the following features:

- GIT
- Docker
- Docker-compose

### Docker

You can find the installation instructions [here](https://docs.docker.com/engine/installation).

### Docker-compose

We suggest to install Docker-compose as a container, in your userland (no root required!):
```bash
# Create your home bin for local user installation if it does not exist
$ mkdir ~/bin
# Download docker-compose shell script locally
# Note: replace the version by the latest available
$ curl -L --fail https://github.com/docker/compose/releases/download/1.16.1/run.sh > ~/bin/docker-compose
# Make docker-compose an executable
$ chmod u+x ~/bin/docker-compose
# Source the ~/bin folder
# Note: don't forget to add it in your ~/.bashrc ("export PATH=$HOME/bin:$PATH")
$ source ~/bin
# Check if installation is ok
$ docker-compose --version
```
This script is provided by the Docker-compose team and will download the official image at the first launch and build it.

You can find the full documentation [here](https://docs.docker.com/compose/install).


## Usage

See [Usage](usage.md) section.


## Contributing

Have a look at the [Contributing section](.github/CONTRIBUTING.md). If you have any question feel free to discuss about it on our [Gitter](https://gitter.im/ovh/ux).


## Credits

Based on the [`drupal-docker`](https://github.com/peperoni60/drupal-docker) project.

Some of the containers are provided by Wodby.


## License

GPL 3.0 (original license)

---
