#!/bin/bash
# Demyx
# https://demyx.sh

# If ELGG_HTTPS is true then set the protocol to https
[[ "$ELGG_HTTPS" = true ]] && ELGG_WWWROOT="https://${ELGG_DOMAIN}/"

# Install Elgg if this file doesn't exist
if [[ ! -f "$ELGG_ROOT"/elgg-config/settings.php ]]; then
    echo "Elgg is missing, installing now..."
    cp -R "$ELGG_CONFIG"/elgg/* "$ELGG_ROOT"

    if [[ -n "$ELGG_DBUSER" && -n "$ELGG_DBPASSWORD" && -n "$ELGG_DBNAME" && -n "$ELGG_DBHOST" ]]; then
        sed -i 's|$enabled = false|$enabled = true|g' "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'dbuser' => ''|'dbuser' => '$ELGG_DBUSER'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'dbpassword' => ''|'dbpassword' => '$ELGG_DBPASSWORD'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'dbname' => ''|'dbname' => '$ELGG_DBNAME'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'sitename' => ''|'sitename' => '$ELGG_SITENAME'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'siteemail' => ''|'siteemail' => '$ELGG_SITEEMAIL'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'wwwroot' => ''|'wwwroot' => '$ELGG_WWWROOT'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'dataroot' => ''|'dataroot' => '$ELGG_ROOT'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'displayname' => ''|'displayname' => '$ELGG_DISPLAYNAME'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'email' => ''|'email' => '$ELGG_SITEEMAIL'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'username' => ''|'username' => '$ELGG_USERNAME'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|'password' => ''|'password' => '$ELGG_PASSWORD'|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        sed -i "s|];|'dbhost' => '$ELGG_DBHOST','timezone' => '$TZ'];|g" "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php

        # Initiate installer
        php "$ELGG_CONFIG"/elgg-git/install/cli/sample_installer.php
        mv "$ELGG_CONFIG"/elgg-git/elgg-config/settings.php "$ELGG_ROOT"/elgg-config
        rm "$ELGG_ROOT"/install.php
    else
        echo "One or more environment variables missing, exiting..."
        exit 1
    fi
fi
