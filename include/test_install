#!/bin/bash

export CFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"
export CXXFLAGS="-march=native -w -Wno-psabi -D_FILE_OFFSET_BITS=64"

LIBXISF_COMMIT="v0.2.12"
INDI_COMMIT="v1.9.1"
INDI_3RD_COMMIT="v1.9.1"

# you can set custom BUILD_DIR
BUILD_DIR=${BUILD_DIR:-$HOME}
ROOTDIR="$BUILD_DIR/AstroPi"

JOBS=$(grep -c ^processor /proc/cpuinfo)

# 64 bit systems need more memory for compilation
if [ $(getconf LONG_BIT) -eq 64 ] && [ $(grep MemTotal < /proc/meminfo | cut -f 2 -d ':' | sed s/kB//) -lt 5000000 ]
then
	echo "Low memory limiting to JOBS=2"
	JOBS=2
fi

[ ! -d "$ROOTDIR" ] && mkdir -p "$ROOTDIR"
cd "$ROOTDIR"

[ ! -d "libXISF" ] && { git clone https://gitea.nouspiro.space/nou/libXISF.git || { echo "Failed to clone LibXISF"; exit 1; } }
cd libXISF
git fetch origin
git switch -d --discard-changes $LIBXISF_COMMIT
[ ! -d ../build-libXISF ] && { cmake -B ../build-libXISF ../libXISF -DCMAKE_BUILD_TYPE=Release || { echo "LibXISF configuration failed"; exit 1; } }
cd ../build-libXISF
make -j $JOBS || { echo "LibXISF compilation failed"; exit 1; }
sudo make install || { echo "LibXISF installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi" ] && { git clone https://github.com/indilib/indi.git || { echo "Failed to clone indi"; exit 1; } }
cd indi
git fetch origin
git switch -d --discard-changes $INDI_COMMIT
[ ! -d ../build-indi ] && { cmake -B ../build-indi ../indi -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI configuration failed"; exit 1; } }
cd ../build-indi
make -j $JOBS || { echo "INDI compilation failed"; exit 1; }
sudo make install || { echo "INDI installation failed"; exit 1; }

cd "$ROOTDIR"
[ ! -d "indi-3rdparty" ] && { git clone https://github.com/indilib/indi-3rdparty.git || { echo "Failed to clone indi 3rdparty"; exit 1; } }
cd indi-3rdparty
git fetch origin
git switch -d --discard-changes $INDI_3RD_COMMIT
[ ! -d ../build-indi-lib ] && { cmake -B ../build-indi-lib ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_LIBS=1 -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
cd ../build-indi-lib
make -j $JOBS || { echo "INDI lib compilation failed"; exit 1; }
sudo make install || { echo "INDI lib installation failed"; exit 1; }

[ ! -d ../build-indi-3rdparty ] && { cmake -B ../build-indi-3rdparty ../indi-3rdparty -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release || { echo "INDI lib configuration failed"; exit 1; } }
cd ../build-indi-3rdparty
make -j $JOBS || { echo "INDI 3rd-party compilation failed"; exit 1; }
sudo make install || { echo "INDI lib installation failed"; exit 1; }
