# elgg
[![Build Status](https://img.shields.io/travis/demyxco/elgg?style=flat)](https://travis-ci.org/demyxco/elgg)
[![Docker Pulls](https://img.shields.io/docker/pulls/demyx/elgg?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Architecture](https://img.shields.io/badge/linux-amd64-important?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Alpine](https://img.shields.io/badge/alpine-3.12.0-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![NGINX](https://img.shields.io/badge/nginx-1.19.2-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![PHP](https://img.shields.io/badge/php-7.3.21-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Elgg](https://img.shields.io/badge/elgg-3.3.8-informational?style=flat&color=blue)](https://hub.docker.com/r/demyx/elgg)
[![Buy Me A Coffee](https://img.shields.io/badge/buy_me_coffee-$5-informational?style=flat&color=blue)](https://www.buymeacoffee.com/VXqkQK5tb)
[![Become a Patron!](https://img.shields.io/badge/become%20a%20patron-$5-informational?style=flat&color=blue)](https://www.patreon.com/bePatron?u=23406156)

Elgg is an award-winning open source social networking engine that provides a robust framework on which to build all kinds of social environments, from a campus wide social network for your university, school or college or an internal collaborative platform for your organization through to a brand-building communications tool for your company and its clients. 

DEMYX | ELGG
--- | ---
PORT | 80 9000
USER | demyx
WORKDIR | /demyx
CONFIG | /etc/demyx
LOG | /var/log/demyx
ENTRYPOINT | ["dumb-init", "demyx"]
ELGG | https://domain.tld/
PHP | /etc/demyx/php
NGINX | /etc/demyx/nginx

## Usage
- This docker-compose.yml is designed for VPS use with SSL/TLS first
- Traefik requires no additional configurations and is ready to go
- Be sure to change all the domain.tld domains and credentials before running docker-compose up -d

```
# Demyx
# https://demyx.sh

version: "3.7"
services:
  demyx_socket:
    # Uncomment below if your host OS is CentOS/RHEL/Fedora
    #privileged: true
    image: demyx/docker-socket-proxy
    container_name: demyx_socket
    restart: unless-stopped
    networks:
      - demyx_socket
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - CONTAINERS=1
  demyx_traefik:
    image: demyx/traefik
    container_name: demyx_traefik
    restart: unless-stopped
    depends_on: 
      - demyx_socket
    networks:
      - demyx
      - demyx_socket
    ports:
      - 80:8081
      - 443:8082
    volumes:
      - demyx_traefik:/demyx
      - demyx_log:/var/log/demyx
    environment:
      - TRAEFIK_PROVIDERS_DOCKER_ENDPOINT=tcp://demyx_socket:2375
      - TRAEFIK_API=true
      - TRAEFIK_PROVIDERS_DOCKER=true
      - TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT=false
      # Uncomment if using Cloudflare to get client real IP
      #- TRAEFIK_ENTRYPOINTS_HTTPS_FORWARDEDHEADERS_TRUSTEDIPS=173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/12,172.64.0.0/13,131.0.72.0/22
      - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_HTTPCHALLENGE=true
      - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_HTTPCHALLENGE_ENTRYPOINT=http
      - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_EMAIL=info@domain.tld
      - TRAEFIK_CERTIFICATESRESOLVERS_DEMYX_ACME_STORAGE=/demyx/acme.json
      - TRAEFIK_LOG=true
      - TRAEFIK_LOG_LEVEL=INFO
      - TRAEFIK_LOG_FILEPATH=/var/log/demyx/traefik.error.log
      - TRAEFIK_ACCESSLOG=true
      - TRAEFIK_ACCESSLOG_FILEPATH=/var/log/demyx/traefik.access.log
      - TZ=America/Los_Angeles
    labels:
      # Traefik Dashboard - https://traefik.domain.tld
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-https.rule=Host(`traefik.domain.tld`)" 
      - "traefik.http.routers.traefik-https.entrypoints=https"
      - "traefik.http.routers.traefik-https.service=api@internal"
      - "traefik.http.routers.traefik-https.tls.certresolver=demyx"
      - "traefik.http.routers.traefik-https.middlewares=traefik-https-auth"
      - "traefik.http.middlewares.traefik-https-auth.basicauth.users=demyx:$$apr1$$EqJj89Yw$$WLsBIjCILtBGjHppQ76YT1" # Password: demyx
  demyx_db:
    container_name: demyx_db
    image: demyx/mariadb
    restart: unless-stopped
    depends_on: 
      - demyx_traefik
    networks:
      - demyx
    volumes:
      - demyx_db:/demyx
      - demyx_log:/var/log/demyx
    environment:
      - MARIADB_DATABASE=demyx
      - MARIADB_USERNAME=demyx
      - MARIADB_PASSWORD=demyx
      - MARIADB_ROOT_PASSWORD=demyx # Mandatory
      - MARIADB_ROOT=/demyx
      - MARIADB_CONFIG=/etc/demyx
      - MARIADB_LOG=/var/log/demyx
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
  demyx_elgg:
    container_name: demyx_elgg
    image: demyx/elgg
    restart: unless-stopped
    depends_on: 
      - demyx_db
    networks:
      - demyx
    volumes:
      - demyx_elgg:/demyx
      - demyx_log:/var/log/demyx
    environment:
      - ELGG_DBHOST=demyx_db
      - ELGG_DBNAME=demyx
      - ELGG_DBUSER=demyx
      - ELGG_DBPASSWORD=demyx
      - ELGG_DOMAIN=domain.tld
      - ELGG_SITENAME=demyx
      - ELGG_HTTPS=true
      - ELGG_WWWROOT=https://domain.tld/
      - ELGG_DISPLAYNAME=demyx
      - ELGG_SITEEMAIL=info@domain.tld
      - ELGG_USERNAME=demyx
      - ELGG_PASSWORD=demyxdemyx # Because demyx was too short of a password
      - ELGG_UPLOAD_LIMIT=128M
      - ELGG_PHP_OPCACHE=true
      - ELGG_PHP_PM=ondemand
      - ELGG_PHP_PM_MAX_CHILDREN=100
      - ELGG_PHP_PM_START_SERVERS=10
      - ELGG_PHP_PM_MIN_SPARE_SERVERS=5
      - ELGG_PHP_PM_MAX_SPARE_SERVERS=25
      - ELGG_PHP_PM_PROCESS_IDLE_TIMEOUT=5s
      - ELGG_PHP_PM_MAX_REQUESTS=500
      - ELGG_PHP_MAX_EXECUTION_TIME=300
      - ELGG_PHP_MEMORY=256M
      - TZ=America/Los_Angeles
    labels:
      # Elgg - https://domain.tld/
      - "traefik.enable=true"
      # HTTP
      - "traefik.http.routers.elgg-http.rule=Host(`domain.tld`) || Host(`www.domain.tld`)"
      - "traefik.http.routers.elgg-http.entrypoints=http"
      # HTTP port
      - "traefik.http.routers.elgg-http.service=elgg-http-port"
      - "traefik.http.services.elgg-http-port.loadbalancer.server.port=80"
      # HTTP redirect to HTTPS
      - "traefik.http.routers.elgg-http.middlewares=elgg-redirect"
      - "traefik.http.middlewares.elgg-redirect.redirectscheme.scheme=https"
      # HTTPS
      - "traefik.http.routers.elgg-https.rule=Host(`domain.tld`) || Host(`www.domain.tld`)"
      - "traefik.http.routers.elgg-https.entrypoints=https"
      - "traefik.http.routers.elgg-https.tls.certresolver=demyx"
      # HTTPS port
      - "traefik.http.routers.elgg-https.service=elgg-https-port"
      - "traefik.http.services.elgg-https-port.loadbalancer.server.port=80"
volumes:
  demyx_elgg:
    name: demyx_elgg
  demyx_db:
    name: demyx_db
  demyx_traefik:
    name: demyx_traefik
  demyx_log:
    name: demyx_log
networks:
  demyx:
    name: demyx
  demyx_socket:
    name: demyx_socket
```

## Updates & Support
[![Code Size](https://img.shields.io/github/languages/code-size/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Repository Size](https://img.shields.io/github/repo-size/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Watches](https://img.shields.io/github/watchers/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Stars](https://img.shields.io/github/stars/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)
[![Forks](https://img.shields.io/github/forks/demyxco/elgg?style=flat&color=blue)](https://github.com/demyxco/elgg)

* Auto built weekly on Saturdays (America/Los_Angeles)
* Rolling release updates
* For support: [#demyx](https://webchat.freenode.net/?channel=#demyx)
