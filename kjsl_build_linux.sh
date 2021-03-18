#!/bin/bash
git clone https://github.com/kevleyski/nginx-rtmp-module nginx-rtmp-module
git clone https://github.com/kevleyski/ngx_devel_kit ngx_devel_kit 

if [ ! -d openssl-MetaCDN_20210318 ]; then
wget https://github.com/MetaCDN/openssl/archive/MetaCDN_20210318.tar.gz
tar -zxf MetaCDN_20210318.tar.gz
cd openssl-MetaCDN_20210318
./Configure --prefix=/usr
make -j $(nproc)
sudo make install
cd ..
fi

if [ ! -d zlib-1.2.11 ]; then
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make -j $(nproc)
sudo make install
cd ..
fi

if [ ! -d pcre-8.42 ]; then
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.42.tar.gz
tar -zxf pcre-8.42.tar.gz
cd pcre-8.42
./configure
make -j $(nproc)
sudo make install
cd ..
fi

mkdir -p /usr/nginx
mkdir -p /usr/nginx/nginx
./auto/configure --prefix=/etc/nginx \
	--with-cc-opt="-I/usr/include" \
	--with-ld-opt="-L/usr/lib" \
 --with-select_module \
            --with-poll_module \
            --with-threads \
            --with-file-aio \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_xslt_module=dynamic \
            --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_auth_request_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_degradation_module \
            --with-http_slice_module \
            --with-http_perl_module=dynamic \
            --with-perl_modules_path=/usr/share/perl/5.26.1 \
            --with-perl=/usr/bin/perl \
            --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --with-stream_realip_module \
            --with-stream_geoip_module=dynamic \
        --with-compat \
        --with-openssl=/usr/include/openssl \
	--with-openssl-opt=enable-tls1_3 \
        --with-http_stub_status_module

make -j $(nproc)
sudo make install

nginx -V
