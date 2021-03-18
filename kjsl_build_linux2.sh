#!/bin/bash

## TODO:
# Figure out how to get nginx file-aio module working (incompatible?)

## Get and install tools and dependencies
sudo apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev libbz2-dev

## Get installed OpenSSL version
# Use `whereis openssl` to check if installed first
OPENSSL_INSTALLED=$(/usr/bin/openssl version 2>&1); OPENSSL_INSTALLED=${OPENSSL_INSTALLED:8:6}
echo "Installed OpenSSL version: $OPENSSL_INSTALLED"

## Get latest OpenSSL version
OPENSSL_LATEST=`wget -qO- --no-check-certificate https://www.openssl.org/source/ | egrep -o 'openssl-[A-Za-z0-9\.]+.tar.gz' | sort -V | tail -1 | sed -nre 's|^[^0-9]*(([0-9]+\.)*[A-Za-z0-9]+).*|\1|p'`
echo "Latest OpenSSL version: $OPENSSL_LATEST"

## Check if OpenSSL version installed is latest
if [[ $OPENSSL_INSTALLED != $OPENSSL_LATEST ]]; then
    ## Install dependencies
    sudo apt-get -y install ca-certificates libssl-dev

    ## Switch to temporary directory
    cd /tmp

    ## Download latest OpenSSL source
    wget -qN https://www.openssl.org/source/openssl-${OPENSSL_LATEST}.tar.gz -O /tmp/openssl-${OPENSSL_LATEST}.tar.gz

    ## Extract latest OpenSSL source
    tar -xvzf openssl-${OPENSSL_LATEST}.tar.gz && cd openssl-${OPENSSL_LATEST}

    ## Configure OpenSSL parameters
    ./config --prefix=/usr zlib-dynamic --openssldir=/etc/ssl shared

    ## Compile and install latest OpenSSL source
    sudo make && sudo make install

    ## Verify latest version is installed
    if [[ $OPENSSL_INSTALLED == $OPENSSL_LATEST ]]; then
        echo "OpenSSL installed successfully!"
    else
        echo "OpenSSL installation failed!"
    fi
fi

## Get installed NGINX version
# Use `whereis nginx` to check if installed first
NGINX_INSTALLED=$(/usr/sbin/nginx -v 2>&1); NGINX_INSTALLED=${NGINX_INSTALLED#*/}
echo "Installed NGINX version: $NGINX_INSTALLED"

## Get latest NGINX version
NGINX_LATEST=`wget -qO- http://nginx.org/en/download.html | egrep -o 'nginx-[0-9\.]+.tar.gz' | sort -V | tail -1 | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p'`
#NGINX_LATEST=`wget -qO- http://nginx.org/en/download.html | sed -n 's|.*/download/nginx-\(.*\).tar.gz.*|\1|p' | awk '{ print $1; exit }'`
echo "Latest NGINX version: $NGINX_LATEST"

## Check if NGINX version installed is latest
if [[ $NGINX_INSTALLED != $NGINX_LATEST ]]; then
    ## Remove existing NGINX version
    sudo apt-get -y remove nginx nginx-common nginx-core nginx-full

    ## Install dependencies
    sudo apt-get -y install geoip-bin libgeoip-dev

    ## Add NGINX user if it doesn't exist
    #useradd --no-create-home www-data

    ## Create NGINX directories if they don't exist
    #mkdir -p /var/lib/nginx/body && mkdir -p /var/lib/nginx/proxy && mkdir -p /var/lib/nginx/fastcgi

    ## Switch to temporary directory
    cd /tmp

    ## Download the latest Headers More module source
    HMM_VERSION=`wget -qO- --no-check-certificate https://github.com/openresty/headers-more-nginx-module/releases | sed -n 's|.*/archive/\(.*\).tar.gz.*|\1|p' | awk '{ print $1; exit }'`
    echo "Latest Headers More module version: $HMM_VERSION"
    wget -qN --no-check-certificate https://github.com/agentzh/headers-more-nginx-module/archive/${HMM_VERSION}.tar.gz -O /tmp/headers-more-${HMM_VERSION}.tar.gz
    tar -xvzf headers-more-${HMM_VERSION}.tar.gz

    ## Download the latest NAXSI WAF module source
    NAXSI_VERSION=`wget -qO- --no-check-certificate https://github.com/nbs-system/naxsi/releases | sed -n 's|.*/archive/\(.*\).tar.gz.*|\1|p' | awk '{ print $1; exit }'`
    echo "Latest NAXSI WAF module version: $NAXSI_VERSION"
    wget -qN --no-check-certificate https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz  -O /tmp/naxsi-${NAXSI_VERSION}.tar.gz
    tar -xvzf naxsi-${NAXSI_VERSION}.tar.gz

    ## Download latest NGINX source
    wget -qN http://nginx.org/download/nginx-${NGINX_LATEST}.tar.gz -O /tmp/nginx-${NGINX_LATEST}.tar.gz

    ## Extract latest NGINX source
    tar -xvzf nginx-${NGINX_LATEST}.tar.gz && cd nginx-${NGINX_LATEST}

    ## Configure NGINX parameters
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/var/lib/nginx/body \
        --http-proxy-temp-path=/var/lib/nginx/proxy \
        --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
        --user=www-data \
        --group=www-data \
        --without-http_autoindex_module \
        --without-http_empty_gif_module \
        --without-http_scgi_module \
        --without-http_split_clients_module \
        --without-http_ssi_module \
        --without-http_userid_module \
        --without-http_uwsgi_module \
        --with-http_geoip_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_ssl_module \
        --with-ipv6 \
        --add-module=/tmp/headers-more-nginx-module-${HMM_VERSION:1:5} \
        --add-module=/tmp/naxsi-${NAXSI_VERSION}/naxsi_src \

    ## Compile and install latest NGINX source
    sudo make && sudo make install

    ## Start NGINX server
    sudo service nginx start

    ## Fetch working control script
    sudo wget --no-check-certificate -qN https://gist.githubusercontent.com/lukespragg/7c9b2974f0eaddc9f2c5/raw/2176862e8607789b41fa99ddfd43e9b66e5a1262/nginx -O /etc/init.d/nginx

    ## Make control script executable
    sudo chmod +x /etc/init.d/nginx

    ## Set NGINX to automatically start
    sudo update-rc.d -f nginx defaults

    ## Force stop and start if all else fails
    sudo /usr/sbin/nginx -s stop && sudo service nginx start

    ## Verify latest version is installed
    if [[ $NGINX_INSTALLED == $NGINX_LATEST ]]; then
        echo "NGINX installed successfully!"
    else
        echo "NGINX installation failed!"
    fi
fi
