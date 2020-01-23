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


cd ~user/src
git clone https://github.com/xblahoud/ltlcross_wrapper.git -b next
cd ltlcross_wrapper
pip3 install .

cd ~user/src
git clone https://github.com/xblahoud/seminator-evaluation.git

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

cd /tmp
git clone https://github.com/ISCAS-PMC/roll-library.git
cd roll-library
./build.sh
mkdir /usr/local/share/roll
cp ROLL.jar /usr/local/share/roll
cat >/usr/local/bin/roll <<EOF
#!/bin/sh
exec java -jar /usr/local/share/roll/ROLL.jar "$@"
EOF
chmod +x /usr/local/bin/roll
cd /tmp
rm -rf roll-library

# seminator-evaluation expect a copy of the ROLL library in
# complement/other_tools/roll-library
cd ~user/src/seminator-evaluation/complement
mkdir -p other_tools/roll-library
cd other_tools/roll-library
ln -s /usr/local/share/roll/ROLL.jar

# GOAL + Fribourg plugin
V=20200107
cd /tmp
wget http://goal.im.ntu.edu.tw/release/GOAL-$V.zip
wget https://frico.s3.amazonaws.com/goal_plugins/ch.unifr.goal.complement.zip
unzip ch.unifr.goal.complement.zip
cd ch.unifr.goal.complement
zip -9 -r ch.unifr.goal.complement.zip classes plugin.xml
cd ~user/src/seminator-evaluation/complement/other_tools
unzip /tmp/GOAL-$V.zip
cd GOAL-$V/plugins
mv /tmp/ch.unifr.goal.complement/ch.unifr.goal.complement.zip .
