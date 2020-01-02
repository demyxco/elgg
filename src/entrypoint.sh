#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Generate configs
demyx-config

# Execute install script
demyx-install

# Start processes
php-fpm
sudo nginx -c "$ELGG_CONFIG"/nginx/elgg.conf -g "daemon off;"
