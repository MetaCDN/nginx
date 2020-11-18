#!/bin/bash
cd openssl-1.1.1g
./Configure darwin64-x86_64-cc --prefix=/usr
make
sudo make install
cd ..

cd zlib-1.2.11
./configure
make
sudo make install
cd ..

cd pcre-8.42
./configure
make
sudo make install
cd ..

