# elgg
[![Build Status](https://img.shields.io/travis/demyxco/elgg?style=flat)](https://travis-ci.org/demyxco/elgg)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/elgg?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Docker Layers](https://img.shields.io/microbadger/layers/demyx/elgg?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Docker Image Size](https://img.shields.io/microbadger/image-size/demyx/elgg?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Alpine](https://img.shields.io/badge/alpine-3.10.2-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![NGINX](https://img.shields.io/badge/nginx-1.17.3-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![PHP](https://img.shields.io/badge/php-7.3.8-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Elgg](https://img.shields.io/badge/elgg-3.1.1-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)

Elgg is an award-winning open source social networking engine that provides a robust framework on which to build all kinds of social environments, from a campus wide social network for your university, school or college or an internal collaborative platform for your organization through to a brand-building communications tool for your company and its clients. 

TITLE | DESCRIPTION
--- | ---
USER<br />GROUP | www-data (82)<br />www-data (82)
WORKDIR | /var/www/html
PORT | 80
TIMEZONE | America/Los_Angeles
PHP | /etc/php7/php.ini<br />/etc/php7/php-fpm.d/php-fpm.conf
NGINX | /etc/nginx/nginx.conf<br />/etc/nginx/cache<br />/etc/nginx/common<br />/etc/nginx/modules<br />

# Updates
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Watches](https://img.shields.io/github/watchers/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Stars](https://img.shields.io/github/stars/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Forks](https://img.shields.io/github/forks/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)

* Auto built weekly on Sundays (America/Los_Angeles)
* Rolling release updates

# Usage
This config requires no .toml for Traefik and is ready to go when running: 
`docker-compose up -d`. If you want SSL, just remove the comments and make sure you have acme.json chmod to 600 (`touch acme.json; chmod 600 acme.json`) before mounting.

```
version: "3.7"

services:
  traefik:
    image: traefik
    container_name: demyx_traefik
    restart: unless-stopped
    command: 
      - --api
      - --api.statistics.recenterrors=100
      - --docker
      - --docker.watch=true
      - --docker.exposedbydefault=false
      - "--entrypoints=Name:http Address::80"
      #- "--entrypoints=Name:https Address::443 TLS"
      - --defaultentrypoints=http
      #- --defaultentrypoints=http,https
      #- --acme
      #- --acme.email=info@domain.tld
      #- --acme.storage=/etc/traefik/acme.json
      #- --acme.entrypoint=https
      #- --acme.onhostrule=true
      #- --acme.httpchallenge.entrypoint=http
      - --logLevel=INFO
      - --accessLog.filePath=/etc/traefik/access.log
      - --traefikLog.filePath=/etc/traefik/traefik.log
    networks:
      - demyx
    ports:
      - 80:80
      #- 443:443
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      #- ./acme.json:/etc/traefik/acme.json # chmod 600
    labels:
      - "traefik.enable=true"
      - "traefik.port=8080"
      - "traefik.frontend.rule=Host:traefik.domain.tld"
      #- "traefik.frontend.redirect.entryPoint=https"
      #- "traefik.frontend.auth.basic.users=${DEMYX_STACK_AUTH}"
      #- "traefik.frontend.headers.forceSTSHeader=true"
      #- "traefik.frontend.headers.STSSeconds=315360000"
      #- "traefik.frontend.headers.STSIncludeSubdomains=true"
      #- "traefik.frontend.headers.STSPreload=true"
  elgg_db:
    container_name: elgg_db
    image: demyx/mariadb
    restart: unless-stopped
    networks:
      - demyx
    volumes:
      - elgg_db:/var/lib/mysql
    environment:
      MARIADB_DATABASE: demyx_db
      MARIADB_USERNAME: demyx_user
      MARIADB_PASSWORD: demyx_password
      MARIADB_ROOT_PASSWORD: demyx_root_password
  elgg:
    container_name: elgg
    image: demyx/elgg
    restart: unless-stopped
    networks:
      - demyx
    volumes:
      - elgg:/var/www/html
    environment:
      ELGG_DOMAIN: domain.tld
      TZ: America/Los_Angeles
    labels:
      - "traefik.enable=true"
      - "traefik.port=80"
      - "traefik.frontend.rule=Host:domain.tld,www.domain.tld"
      #- "traefik.frontend.redirect.entryPoint=https"
      #- "traefik.frontend.auth.basic.users=${DEMYX_STACK_AUTH}"
      #- "traefik.frontend.headers.forceSTSHeader=true"
      #- "traefik.frontend.headers.STSSeconds=315360000"
      #- "traefik.frontend.headers.STSIncludeSubdomains=true"
      #- "traefik.frontend.headers.STSPreload=true"  
volumes:
  elgg:
    name: elgg
  elgg_db:
    name: elgg_db
networks:
  demyx:
    name: demyx
```
