#!/bin/bash

export OS_TARGET=$(fpc -iTO)
export CPU_TARGET=$(fpc -iTP)

export ARCH=$CPU_TARGET-$OS_TARGET

cd $(dirname "$0")

rm -rf release
mkdir -p release/wcx/diskdir
mkdir -p release/wdx/exif
mkdir -p release/wdx/ooinfo
mkdir -p release/wdx/ooxml
mkdir -p release/wdx/similarity
mkdir -p release/wlx/fileinfo

lazbuild wcx/diskdir/src/diskdir.lpi
install -m 644 wcx/diskdir/diskdir.wcx release/wcx/diskdir/

make -C wdx/exif
install -m 644 wdx/exif/exif.wdx release/wdx/exif/

lazbuild wdx/ooinfo/src/OOInfo.lpi
install -m 644 wdx/ooinfo/ooinfo.wdx release/wdx/ooinfo/

make -C wdx/ooxml/src
install -m 644 wdx/ooxml/ooxml.wdx release/wdx/ooxml/

make -C wdx/similarity/src
install -m 644 wdx/similarity/similarity.wdx release/wdx/similarity/
install -m 644 wdx/similarity/leven.ini      release/wdx/similarity/
install -m 644 wdx/similarity/readme.txt     release/wdx/similarity/

wlx/fileinfo/build.sh
install -m 644 wlx/fileinfo/fileinfo.wlx release/wlx/fileinfo/
install -m 755 wlx/fileinfo/fileinfo.sh  release/wlx/fileinfo/

pushd release
tar -czpf ../plugins-$ARCH.tar.gz *
popd