#!/bin/sh

set -e  # Abort on any error
set -x  # Show each instruction as it is run

mkdir ~user/src
cd ~user/src
# Seminator
V=1.99
wget https://github.com/mklokocka/seminator/releases/download/v$V/seminator-$V.tar.gz
tar xvf seminator-$V.tar.gz
cd seminator-$V
./configure
make -j4
make install
ldconfig
make clean
mkdir -p /usr/local/share/doc/seminator
cp COPYING README.md /usr/local/share/doc/seminator
cd ../..
ln -s ~user/src/seminator-$V/notebooks/


cd /tmp
# Owl
V=19.06.03
wget https://owl.model.in.tum.de/files/owl-$V.zip
mkdir -p /usr/local/share/
unzip owl-$V.zip -d /usr/local/share/
rm -f owl-$V.zip
for i in delag dra2dpa fgx2dpa ltl2dgmra ltl2da ltl2dgra ltl2dpa ltl2dra \
         ltl2ldgba ltl2na ltl2nba ltl2ngba nba2dpa nba2ldba owl owl-client \
         owl-server synth
do
    ln -s /usr/local/share/owl-$V/bin/$i /usr/local/bin/
done
