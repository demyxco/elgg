#!/bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

##########################################################################
##########################################################################
############################## NGINX CONFIG ##############################
##########################################################################
##########################################################################

# Cloudflare check
ELGG_CLOUDFLARE_CHECK="$(curl -m 1 -svo /dev/null "$ELGG_DOMAIN" 2>&1 | grep "Server: cloudflare" || true)"
if [[ -n "$ELGG_CLOUDFLARE_CHECK" ]]; then
    ELGG_REAL_IP="real_ip_header CF-Connecting-IP; set_real_ip_from 0.0.0.0/0;"
else
    ELGG_REAL_IP="real_ip_header X-Forwarded-For; set_real_ip_from 0.0.0.0/0;"
fi

echo "#load_module /etc/nginx/modules/ngx_http_cache_purge_module.so;
#load_module /etc/nginx/modules/ngx_http_headers_more_filter_module.so;

error_log stderr notice;
error_log /var/log/demyx/${ELGG_DOMAIN}.error.log;
pid ${ELGG_CONFIG}/nginx/nginx.pid;

worker_processes  auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 100000;
pcre_jit on;

events {
    worker_connections  1024;
    multi_accept on;
    accept_mutex on;
    use epoll;
}

http {

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

    sendfile on;
    sendfile_max_chunk 512k;

    include    /etc/nginx/mime.types;
    include    /etc/nginx/fastcgi.conf;

    default_type application/octet-stream;

    access_log stdout;
    access_log /var/log/demyx/${ELGG_DOMAIN}.access.log main;
    
    tcp_nopush   on;
    tcp_nodelay  on;

    keepalive_timeout 8;
    keepalive_requests 500;
    keepalive_disable msie6;

    lingering_time 20s;
    lingering_timeout 5s;

    server_tokens off;
    reset_timedout_connection on;
    
    add_header X-Powered-By \"Demyx\";
    add_header X-Frame-Options \"SAMEORIGIN\";
    add_header X-XSS-Protection  \"1; mode=block\" always;
    add_header X-Content-Type-Options \"nosniff\" always;
    add_header Referrer-Policy \"strict-origin-when-cross-origin\";
    add_header X-Download-Options \"noopen\";
    add_header Feature-Policy \"geolocation 'self'; midi 'self'; sync-xhr 'self'; microphone 'self'; camera 'self'; magnetometer 'self'; gyroscope 'self'; speaker 'self'; fullscreen 'self'; payment 'self'; usb 'self'\";
    add_header Strict-Transport-Security \"max-age=31536000; preload; includeSubDomains\" always;

    client_max_body_size $ELGG_UPLOAD_LIMIT;
    client_body_timeout 10;
    client_body_temp_path /tmp/nginx-client 1 2;
    fastcgi_temp_path /tmp/nginx-fastcgi 1 2;
    proxy_temp_path /tmp/nginx-proxy;
    uwsgi_temp_path /tmp/nginx-uwsgi;
    scgi_temp_path /tmp/nginx-scgi;
    fastcgi_read_timeout 120s;

    resolver 1.1.1.1 1.0.0.1 valid=300s;
    resolver_timeout 10;

    limit_req_status 503;
    limit_req_zone \$request_uri zone=one:10m rate=1r/s;

    gzip off;

    server {
        listen       80;
        server_name ${ELGG_DOMAIN};
        root $ELGG_ROOT;
        index  index.php index.html index.htm;
        access_log stdout;
        access_log /var/log/demyx/${ELGG_DOMAIN}.access.log main;
        error_log stderr notice;
        error_log /var/log/demyx/${ELGG_DOMAIN}.error.log;

        $ELGG_REAL_IP

        gzip on;
        gzip_types
        # text/html is always compressed by HttpGzipModule
        text/css
        text/javascript
        text/xml
        text/plain
        text/x-component
        application/javascript
        application/x-javascript
        application/json
        application/xml
        application/rss+xml
        font/truetype
        font/opentype
        application/vnd.ms-fontobject
        image/svg+xml;

        location ~ (^\.|/\.) {
            return 403;
        }

        location = /rewrite.php {
            rewrite ^(.*)\$ /install.php;
        }

        location / {
            try_files \$uri \$uri/ @elgg;
        }

        location /cache/ {
            disable_symlinks off;
            expires 1y;
            try_files \$uri \$uri/ @elgg;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ \.php\$ {
            try_files \$uri @elgg;
            fastcgi_index index.php;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include /etc/nginx/fastcgi_params;
        }

        location @elgg {
            fastcgi_pass 127.0.0.1:9000;
            include /etc/nginx/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root/index.php;
            fastcgi_param SCRIPT_NAME     /index.php;
            fastcgi_param QUERY_STRING    __elgg_uri=\$uri&\$args;
            limit_req zone=one burst=5 nodelay;
        }

        include ${ELGG_CONFIG}/nginx/common/*.conf;

    }

}" > "$ELGG_CONFIG"/nginx/elgg.conf

##########################################################################
##########################################################################
############################### PHP CONFIG ###############################
##########################################################################
##########################################################################

# PHP opcache
if [[ "$ELGG_PHP_OPCACHE" = false ]]; then
    ELGG_PHP_OPCACHE_ENABLE=0
    ELGG_PHP_OPCACHE_ENABLE_CLI=0
fi

# Generate www.conf
echo "[${ELGG_DOMAIN}]
listen                      = 9000
pm                          = $ELGG_PHP_PM
pm.max_children             = $ELGG_PHP_PM_MAX_CHILDREN
pm.start_servers            = $ELGG_PHP_PM_START_SERVERS
pm.min_spare_servers        = $ELGG_PHP_PM_MIN_SPARE_SERVERS
pm.max_spare_servers        = $ELGG_PHP_PM_MAX_SPARE_SERVERS
pm.process_idle_timeout     = $ELGG_PHP_PM_PROCESS_IDLE_TIMEOUT
pm.max_requests             = $ELGG_PHP_PM_MAX_REQUESTS
chdir                       = $ELGG_ROOT
catch_workers_output        = yes
php_admin_value[error_log]  = /var/log/demyx/${ELGG_DOMAIN}.error.log
" > "$ELGG_CONFIG"/php/www.conf

# Generate docker.conf
echo "[global]
error_log = /proc/self/fd/2

; https://github.com/docker-library/php/pull/725#issuecomment-443540114
log_limit = 8192

[${ELGG_DOMAIN}]
; if we send this to /proc/self/fd/1, it never appears
access.log = /proc/self/fd/2

clear_env = no

; Ensure worker stdout and stderr are sent to the main error log.
catch_workers_output = yes
decorate_workers_output = no
" > "$ELGG_CONFIG"/php/docker.conf

# Generate php.ini
echo "[PHP]
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions = pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,
disable_classes =
zend.enable_gc = On
expose_php = Off
max_execution_time = $ELGG_PHP_MAX_EXECUTION_TIME
max_input_vars = 20000
max_input_time = 600
memory_limit = $ELGG_PHP_MEMORY
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
html_errors = On
variables_order = \"GPCS\"
request_order = \"GP\"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = $ELGG_UPLOAD_LIMIT
auto_prepend_file =
auto_append_file =
default_mimetype = \"text/html\"
default_charset = \"UTF-8\"
doc_root =
user_dir =
enable_dl = Off
file_uploads = On
upload_max_filesize = $ELGG_UPLOAD_LIMIT
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60

[CLI Server]
cli_server.color = On

[Date]
date.timezone = $TZ
[filter]

[iconv]

[intl]

[sqlite3]

[Pcre]

[Pdo]

[Pdo_mysql]
pdo_mysql.default_socket=

[Phar]

[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = On

[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1

[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = \"%Y-%m-%d %H:%M:%S\"
ibase.dateformat = \"%Y-%m-%d\"
ibase.timeformat = \"%H:%M:%S\"

[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off

[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off

[OCI8]

[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0

[bcmath]
bcmath.scale = 0

[browscap]

[Session]
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.cookie_samesite =
session.serialize_handler = php
session.gc_probability = 0
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.sid_length = 26
session.trans_sid_tags = \"a=href,area=href,frame=src,form=\"
session.sid_bits_per_character = 5

[Assertion]
zend.assertions = -1

[COM]

[mbstring]

[gd]

[exif]

[Tidy]
tidy.clean_output = Off

[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir=\"/tmp\"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5

[sysvshm]

[ldap]
ldap.max_links = -1

[dba]

[opcache]
opcache.enable=${ELGG_PHP_OPCACHE_ENABLE:-1}
opcache.enable_cli=${ELGG_PHP_OPCACHE_ENABLE:-1}
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.max_wasted_percentage=10
opcache.memory_consumption=256
opcache.save_comments=1
opcache.revalidate_freq=60
opcache.validate_timestamps=1
opcache.consistency_checks=0

[curl]

[openssl]
" > "$ELGG_CONFIG"/php/php.ini
