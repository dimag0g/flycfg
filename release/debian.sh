#!/bin/sh

rm -fr DEBUILD
set -v
set -e

version=`git -C .. describe --tags`
prev_version=`git describe --tags --abbrev=0 HEAD~1`

mkdir -p flycfg-$version/locale
cp ../*.lpi ../*.lpr ../*.pas ../*.lfm ../*.ico flycfg-$version/
cp ../*.ini flycfg-$version/
mkdir -p flycfg-$version/locale
cp ../locale/*.po flycfg-$version/locale
mkdir -p flycfg-$version/TLazSerial
cp ../TLazSerial/*.* flycfg-$version/TLazSerial/


tar czf flycfg_$version.orig.tar.gz flycfg-$version
mkdir -p DEBUILD
mv flycfg-$version DEBUILD
mv flycfg_$version.orig.tar.gz DEBUILD


mkdir -p DEBUILD/flycfg-$version/debian/source
echo "1.0" > DEBUILD/flycfg-$version/debian/source/format
echo "10" > DEBUILD/flycfg-$version/debian/compat
source /etc/os-release

printf "flycfg ($version-1) $VERSION_CODENAME; urgency=low\n\n" > DEBUILD/flycfg-$version/debian/changelog
git -C .. log --pretty='format:  * %s' $prev_version..HEAD >> DEBUILD/flycfg-$version/debian/changelog
printf "\n\n -- Dmitry Grigoryev <dmitry.grigoryev@outlook.com>  $(date -R)\n" >> DEBUILD/flycfg-$version/debian/changelog

cp debian/* DEBUILD/flycfg-$version/debian/
chmod +x DEBUILD/flycfg-$version/debian/rules
cd DEBUILD/flycfg-$version

if [[ -n "$WSL_DISTRO_NAME" ]]; then
    debuild -us -uc -b -d -rsudo
else
    debuild -us -uc -b -d
fi
