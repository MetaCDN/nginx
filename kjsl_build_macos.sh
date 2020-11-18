#!/bin/bash
if [ ! -d nginx-rtmp-module ]; then
git clone https://github.com/kevleyski/nginx-rtmp-module nginx-rtmp-module
fi

if [ ! -d ngx_devel_kit ]; then
git clone https://github.com/kevleyski/ngx_devel_kit ngx_devel_kit 
fi

if [ ! -d openssl-1.1.1g ]; then
wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar -zxf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g
./Configure darwin64-x86_64-cc --prefix=/usr
make
sudo make install
cd ..
fi

if [ ! -d zlib-1.2.11 ]; then
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
sudo make install
cd ..
fi

if [ ! -d pcre-8.42 ]; then
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.42.tar.gz
tar -zxf pcre-8.42.tar.gz
cd pcre-8.42
./configure
make
sudo make install
cd ..
fi

mkdir -p /usr/local/nginx
mkdir -p /usr/local/nginx/nginx
auto/configure --prefix=/usr/local/etc/nginx \
	--with-cc-opt="-I/usr/local/include -I/usr/local/opt/openssl/include" \
	--with-ld-opt="-L/usr/local/lib -L/usr/local/opt/openssl/lib" \
	--prefix=/usr/local/etc/nginx \
	--with-http_ssl_module \
	--with-http_v2_module \
	--sbin-path=/usr/local/sbin/nginx \
	--conf-path=/usr/local/etc/nginx/nginx.conf \
	--error-log-path=/usr/local/var/log/nginx/error.log \
	--http-log-path=/usr/local/var/log/nginx/access.log \
	--pid-path=/usr/local/var/run/nginx.pid \
	--lock-path=/usr/local/var/run/nginx.lock \
	--add-module=./ngx_devel_kit \
 	--add-module=./nginx-rtmp-module \
 	--add-module=./nginx_kevs

make -j9
sudo make install

nginx -V
