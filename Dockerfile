FROM nginx:alpine

LABEL sh.demyx.image demyx/elgg
LABEL sh.demyx.maintainer Demyx <info@demyx.sh>
LABEL sh.demyx.url https://demyx.sh
LABEL sh.demyx.github https://github.com/demyxco
LABEL sh.demyx.registry https://hub.docker.com/u/demyx

# Set default variables
ENV ELGG_ROOT=/demyx
ENV ELGG_CONFIG=/etc/demyx
ENV ELGG_LOG=/var/log/demyx
ENV ELGG_DOMAIN=domain.tld
ENV ELGG_SITENAME=demyx
ENV ELGG_HTTPS=false
ENV ELGG_WWWROOT=http://"$ELGG_DOMAIN"/
ENV ELGG_DISPLAYNAME=demyx
ENV ELGG_SITEEMAIL=info@"$ELGG_DOMAIN"
ENV ELGG_USERNAME=demyx
ENV ELGG_PASSWORD=demyxdemyx
ENV ELGG_UPLOAD_LIMIT=128M
ENV ELGG_PHP_OPCACHE=true
ENV ELGG_PHP_PM=ondemand
ENV ELGG_PHP_PM_MAX_CHILDREN=100
ENV ELGG_PHP_PM_START_SERVERS=10
ENV ELGG_PHP_PM_MIN_SPARE_SERVERS=5
ENV ELGG_PHP_PM_MAX_SPARE_SERVERS=25
ENV ELGG_PHP_PM_PROCESS_IDLE_TIMEOUT=5s
ENV ELGG_PHP_PM_MAX_REQUESTS=500
ENV ELGG_PHP_MAX_EXECUTION_TIME=300
ENV ELGG_PHP_MEMORY=256M
ENV TZ America/Los_Angeles

# Configure Demyx
RUN set -ex; \
    addgroup -g 1000 -S demyx; \
    adduser -u 1000 -D -S -G demyx demyx; \
    \
    install -d -m 0755 -o demyx -g demyx "$ELGG_ROOT"; \
    install -d -m 0755 -o demyx -g demyx "$ELGG_CONFIG"; \
    install -d -m 0755 -o demyx -g demyx "$ELGG_LOG"

#    
# BUILD CUSTOM MODULES
#
RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    gnupg1 \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    git \
    \
    && export NGINX_VERSION="$(wget -qO- https://raw.githubusercontent.com/nginxinc/docker-nginx/master/mainline/alpine/Dockerfile | grep 'ENV NGINX_VERSION' | cut -c 19-)" \
    && mkdir -p /usr/src \
    && git clone https://github.com/FRiCKLE/ngx_cache_purge.git /usr/src/ngx_cache_purge \
    && git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/headers-more-nginx-module \
    && wget https://nginx.org/download/nginx-"$NGINX_VERSION".tar.gz -qO /usr/src/nginx.tar.gz \
    && tar -xzf /usr/src/nginx.tar.gz -C /usr/src \
    && rm /usr/src/nginx.tar.gz \
    && sed -i "s/HTTP_MODULES/#HTTP_MODULES/g" /usr/src/ngx_cache_purge/config \
    && sed -i "s/NGX_ADDON_SRCS/#NGX_ADDON_SRCS/g" /usr/src/ngx_cache_purge/config \
    && sed -i "s|ngx_addon_name=ngx_http_cache_purge_module|ngx_addon_name=ngx_http_cache_purge_module; if test -n \"\$ngx_module_link\"; then ngx_module_type=HTTP; ngx_module_name=ngx_http_cache_purge_module; ngx_module_srcs=\"\$ngx_addon_dir/ngx_cache_purge_module.c\"; . auto/module; else HTTP_MODULES=\"\$HTTP_MODULES ngx_http_cache_purge_module\"; NGX_ADDON_SRCS=\"\$NGX_ADDON_SRCS \$ngx_addon_dir/ngx_cache_purge_module.c\"; fi|g" /usr/src/ngx_cache_purge/config \
    && sed -i "s|ngx_addon_name=ngx_http_headers_more_filter_module|ngx_addon_name=ngx_http_headers_more_filter_module; if test -n \"\$ngx_module_link\"; then ngx_module_type=HTTP; ngx_module_name=ngx_http_headers_more_filter_module; ngx_module_srcs=\"\$ngx_addon_dir/ngx_http_headers_more_filter_module.c\"; . auto/module; else HTTP_MODULES=\"\$HTTP_MODULES ngx_http_headers_more_filter_module\"; NGX_ADDON_SRCS=\"\$NGX_ADDON_SRCS \$ngx_addon_dir/ngx_http_headers_more_filter_module.c\"; fi|g" /usr/src/headers-more-nginx-module/config \
    && cd /usr/src/nginx-"$NGINX_VERSION" \
    && ./configure --with-compat --add-dynamic-module=/usr/src/ngx_cache_purge \
    && make modules \
    && cp objs/ngx_http_cache_purge_module.so /etc/nginx/modules \
    && make clean \
    && ./configure --with-compat --add-dynamic-module=/usr/src/headers-more-nginx-module \
    && make modules \
    && cp objs/ngx_http_headers_more_filter_module.so /etc/nginx/modules \
    && rm -rf /usr/src/nginx-"$NGINX_VERSION" /usr/src/ngx_cache_purge /usr/src/headers-more-nginx-module \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*
#    
# END BUILD CUSTOM MODULES
#

# Install php and friends
RUN set -ex; \
    apk add --no-cache bash curl dumb-init git libsodium sudo \
    php7 \
    php7-bcmath \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-ftp \
    php7-gd \
    php7-iconv \
    php7-imagick \
    php7-json \
    php7-mbstring \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pecl-ssh2 \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-soap \
    php7-sodium \
    php7-sockets \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zip \
    php7-zlib; \
    \
    ln -s /usr/sbin/php-fpm7 /usr/local/bin/php-fpm

# Setup sudo
RUN set -ex; \
    echo "demyx ALL=(ALL) NOPASSWD:/usr/sbin/nginx" > /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="ELGG_DOMAIN"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="ELGG_CONFIG"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="ELGG_UPLOAD_LIMIT"' >> /etc/sudoers.d/demyx; \
    echo 'Defaults env_keep +="ELGG_ROOT"' >> /etc/sudoers.d/demyx

# Elgg
RUN set -ex; \
    # Composer
    wget https://getcomposer.org/installer -qO /tmp/composer-setup.php; \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    rm -rf /tmp/*; \
    \
    su -c 'composer create-project elgg/starter-project:dev-master $ELGG_CONFIG/elgg; \
        cd "$ELGG_CONFIG"/elgg; \
        composer install; \
        composer install; \
        \
        git clone https://github.com/Elgg/Elgg.git ${ELGG_CONFIG}/elgg-git; \
        cd ${ELGG_CONFIG}/elgg-git; \
        composer install; \
        \
        composer clearcache' -s /bin/sh demyx; \
    \
    rm -rf /var/cache/apk/*

# Copy files
COPY --chown=demyx:demyx src "$ELGG_CONFIG"

# Finalize
RUN set -ex; \
    # Create php directory
    install -d -m 0755 -o demyx -g demyx "$ELGG_CONFIG"/php; \
    # Symlink php configs
    ln -sf "$ELGG_CONFIG"/php/php.ini /etc/php7/php.ini; \
    ln -sf "$ELGG_CONFIG"/php/www.conf /etc/php7/php-fpm.d/www.conf; \
    ln -s "$ELGG_CONFIG"/php/docker.conf /etc/php7/php-fpm.d/docker.conf; \
    \
    # Migrate scripts
    mv "$ELGG_CONFIG"/config.sh /usr/local/bin/demyx-config; \
    mv "$ELGG_CONFIG"/entrypoint.sh /usr/local/bin/demyx; \
    mv "$ELGG_CONFIG"/install.sh /usr/local/bin/demyx-install; \
    \
    # Make scripts executable
    chmod +x /usr/local/bin/demyx-config; \
    chmod +x /usr/local/bin/demyx; \
    chmod +x /usr/local/bin/demyx-install; \
    \
    # Lock down scripts
    chown -R root:root /usr/local/bin/*

EXPOSE 80 9000

WORKDIR "$ELGG_ROOT"

USER demyx

ENTRYPOINT ["dumb-init", "demyx"]
