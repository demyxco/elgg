# elgg
[![Build Status](https://img.shields.io/travis/demyxco/elgg?style=flat)](https://travis-ci.org/demyxco/elgg)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/elgg?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Alpine](https://img.shields.io/badge/alpine-3.10.2-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![NGINX](https://img.shields.io/badge/nginx-1.17.4-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![PHP](https://img.shields.io/badge/php-7.3.9-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Elgg](https://img.shields.io/badge/elgg-3.1.4-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)

Elgg is an award-winning open source social networking engine that provides a robust framework on which to build all kinds of social environments, from a campus wide social network for your university, school or college or an internal collaborative platform for your organization through to a brand-building communications tool for your company and its clients. 

TITLE | DESCRIPTION
--- | ---
USER<br />GROUP | www-data (82)<br />www-data (82)
WORKDIR | /var/www/html
PORT | 80 9000
ENTRYPOINT | s6-overlay
TIMEZONE | America/Los_Angeles
PHP | /etc/php7/php.ini<br />/etc/php7/php-fpm.d/php-fpm.conf
NGINX | /etc/nginx/nginx.conf<br />/etc/nginx/cache<br />/etc/nginx/common<br />/etc/nginx/modules<br />

## Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Watches](https://img.shields.io/github/watchers/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Stars](https://img.shields.io/github/stars/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Forks](https://img.shields.io/github/forks/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)

* Auto built weekly on Sundays (America/Los_Angeles)
* Rolling release updates
* For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)

## Elgg Container
ENVIRONMENT | VARIABLE
--- | ---
ELGG_DOMAIN | domain.tld 
ELGG_DBUSER | demyx_user 
ELGG_DBPASSWORD | demyx_password 
ELGG_DBNAME | demyx_db 
ELGG_DBHOST | elgg_db 
ELGG_SITENAME | demyx 
ELGG_SITEEMAIL | info@domain.tld 
ELGG_WWWROOT | http://domain.tld/ 
ELGG_DISPLAYNAME | demyx 
ELGG_EMAIL | info@domain.tld 
ELGG_USERNAME | demyx 
ELGG_PASSWORD | demyx_password 
TZ | America/Los_Angeles

## MariaDB Container
ENVIRONMENT | VARIABLE
--- | ---
MARIADB_BINLOG_FORMAT | mixed
MARIADB_CHARACTER_SET_SERVER | utf8
MARIADB_COLLATION_SERVER | utf8_general_ci
MARIADB_DATABASE | # Optional
MARIADB_DEFAULT_CHARACTER_SET | utf8
MARIADB_INNODB_BUFFER_POOL_SIZE | 16M
MARIADB_INNODB_DATA_FILE_PATH | ibdata1:10M:autoextend
MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT | 1
MARIADB_INNODB_LOCK_WAIT_TIMEOUT | 50
MARIADB_INNODB_LOG_BUFFER_SIZE | 8M
MARIADB_INNODB_LOG_FILE_SIZE | 5M
MARIADB_INNODB_USE_NATIVE_AIO | 1
MARIADB_KEY_BUFFER_SIZE | 20M
MARIADB_LOG_BIN | mysql-bin
MARIADB_MAX_ALLOWED_PACKET | 16M
MARIADB_MAX_CONNECTIONS | 151
MARIADB_MYISAM_SORT_BUFFER_SIZE | 8M
MARIADB_NET_BUFFER_SIZE | 8K
MARIADB_PASSWORD | # Optional
MARIADB_READ_BUFFER | 2M
MARIADB_READ_BUFFER_SIZE | 256K
MARIADB_READ_RND_BUFFER_SIZE | 512K
MARIADB_ROOT_PASSWORD | # Required
MARIADB_SERVER_ID | 1
MARIADB_SORT_BUFFER_SIZE | 20M
MARIADB_TABLE_OPEN_CACHE | 64
MARIADB_USERNAME | # Optional
MARIADB_WRITE_BUFFER | 2M

## Usage
* Requires no config file for Traefik and is ready to go when running: `docker-compose up -d`
* For SSL/TLS, just remove the comments (#)
* Upgrading from Traefik v1 to v2? You will need to convert your [acme.json](https://github.com/containous/traefik-migration-tool)

```
version: "3.7"
services:
  traefik:
    image: traefik
    container_name: demyx_traefik
    restart: unless-stopped
    networks:
      - demyx
    ports:
      - 80:80
      #- 443:443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - demyx_traefik:/demyx
    environment:
      - TRAEFIK_API=true
      - TRAEFIK_PROVIDERS_DOCKER=true
      - TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT=false
      - TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS=:80
      #- TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS=:443
      #- TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_HTTPCHALLENGE=true
      #- TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_HTTPCHALLENGE_ENTRYPOINT=http
      #- TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_EMAIL=info@domain.tld
      #- TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_STORAGE=/demyx/acme.json
      - TRAEFIK_LOG=true
      - TRAEFIK_LOG_LEVEL=INFO
      - TRAEFIK_LOG_FILEPATH=/demyx/error.log
      - TRAEFIK_ACCESSLOG=true
      - TRAEFIK_ACCESSLOG_FILEPATH=/demyx/access.log
      - TZ=America/Los_Angeles
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-http.rule=Host(`traefik.domain.tld`)"
      - "traefik.http.routers.traefik-http.service=api@internal"
      - "traefik.http.routers.traefik-http.entrypoints=http"
      #- "traefik.http.routers.traefik-http.middlewares=traefik-redirect"
      #- "traefik.http.routers.traefik-https.rule=Host(`traefik.domain.tld`)"
      #- "traefik.http.routers.traefik-https.entrypoints=https"
      #- "traefik.http.routers.traefik-https.service=api@internal"
      #- "traefik.http.routers.traefik-https.tls.certresolver=demyx"
      #- "traefik.http.routers.traefik-https.middlewares=traefik-auth"
      #- "traefik.http.middlewares.traefik-auth.basicauth.users=demyx:$$apr1$$EqJj89Yw$$WLsBIjCILtBGjHppQ76YT1"
      #- "traefik.http.middlewares.traefik-redirect.redirectscheme.scheme=https"
  elgg_db:
    container_name: elgg_db
    image: demyx/mariadb
    restart: unless-stopped
    networks:
      - demyx
    volumes:
      - elgg_db:/var/lib/mysql
    environment:
      - MARIADB_DATABASE=demyx_db
      - MARIADB_USERNAME=demyx_user
      - MARIADB_PASSWORD=demyx_password
      - MARIADB_ROOT_PASSWORD=demyx_root_password # mandatory
      - MARIADB_BINLOG_FORMAT=mixed
      - MARIADB_CHARACTER_SET_SERVER=utf8
      - MARIADB_COLLATION_SERVER=utf8_general_ci
      - MARIADB_DEFAULT_CHARACTER_SET=utf8
      - MARIADB_INNODB_BUFFER_POOL_SIZE=16M
      - MARIADB_INNODB_DATA_FILE_PATH=ibdata1:10M:autoextend
      - MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT=1
      - MARIADB_INNODB_LOCK_WAIT_TIMEOUT=50
      - MARIADB_INNODB_LOG_BUFFER_SIZE=8M
      - MARIADB_INNODB_LOG_FILE_SIZE=5M
      - MARIADB_INNODB_USE_NATIVE_AIO=1
      - MARIADB_KEY_BUFFER_SIZE=20M
      - MARIADB_LOG_BIN=mysql-bin
      - MARIADB_MAX_ALLOWED_PACKET=16M
      - MARIADB_MAX_CONNECTIONS=151
      - MARIADB_MYISAM_SORT_BUFFER_SIZE=8M
      - MARIADB_NET_BUFFER_SIZE=8K
      - MARIADB_READ_BUFFER=2M
      - MARIADB_READ_BUFFER_SIZE=256K
      - MARIADB_READ_RND_BUFFER_SIZE=512K
      - MARIADB_SERVER_ID=1
      - MARIADB_SORT_BUFFER_SIZE=20M
      - MARIADB_TABLE_OPEN_CACHE=64
      - MARIADB_WRITE_BUFFER=2M
      - TZ=America/Los_Angeles
  elgg:
    container_name: elgg
    image: demyx/elgg
    restart: unless-stopped
    networks:
      - demyx
    volumes:
      - elgg:/var/www/html
    depends_on:
      - elgg_db
    environment:
      - ELGG_DOMAIN=domain.tld
      - ELGG_DBUSER=demyx_user
      - ELGG_DBPASSWORD=demyx_password
      - ELGG_DBNAME=demyx_db
      - ELGG_DBHOST=elgg_db
      - ELGG_SITENAME=demyx
      - ELGG_SITEEMAIL=info@domain.tld
      - ELGG_WWWROOT=http://domain.tld/
      - ELGG_DISPLAYNAME=demyx
      - ELGG_EMAIL=info@domain.tld
      - ELGG_USERNAME=demyx
      - ELGG_PASSWORD=demyx_password
      - TZ=America/Los_Angeles
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.domaintld-http.rule=Host(`domain.tld`) || Host(`www.domain.tld`)"
      - "traefik.http.routers.domaintld-http.entrypoints=http"
      #- "traefik.http.routers.domaintld-http.middlewares=domaintld-redirect"
      #- "traefik.http.routers.domaintld-https.rule=Host(`domain.tld`) || Host(`www.domain.tld`)"
      #- "traefik.http.routers.domaintld-https.entrypoints=https"
      #- "traefik.http.routers.domaintld-https.tls.certresolver=demyx"
      #- "traefik.http.middlewares.domaintld-redirect.redirectscheme.scheme=https"
volumes:
  elgg:
    name: elgg
  elgg_db:
    name: elgg_db
  demyx_traefik:
    name: demyx_traefik
networks:
  demyx:
    name: demyx
```
