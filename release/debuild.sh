#!/bin/sh

rm -fr DEBUILD
set -v
set -e

version=`git -C .. describe --tags`

mkdir -p flycfg-$version/locale
cp ../*.lpi flycfg-$version/
cp ../*.lpr flycfg-$version/
cp ../*.pas flycfg-$version/
cp ../*.lfm flycfg-$version/
cp ../*.ico flycfg-$version/
cp ../*.ini flycfg-$version/
cp ../locale/*.po flycfg-$version/locale


tar czf flycfg_$version.orig.tar.gz flycfg-$version
mkdir -p DEBUILD
mv flycfg-$version DEBUILD
mv flycfg_$version.orig.tar.gz DEBUILD


mkdir -p DEBUILD/flycfg-$version/debian/source
echo "1.0" > DEBUILD/flycfg-$version/debian/source/format
echo "10" > DEBUILD/flycfg-$version/debian/compat
source /etc/os-release

printf "flycfg ($version-1) $VERSION_CODENAME; urgency=low\n\n" > DEBUILD/flycfg-$version/debian/changelog
git -C .. log --pretty='format:  * %s' >> DEBUILD/flycfg-$version/debian/changelog
printf "\n\n -- Dmitry Grigoryev <dmitry.grigoryev@outlook.com>  $(date -R)\n" >> DEBUILD/flycfg-$version/debian/changelog

cp debian/* DEBUILD/flycfg-$version/debian/
chmod +x DEBUILD/flycfg-$version/debian/rules
cd DEBUILD/flycfg-$version
debuild
