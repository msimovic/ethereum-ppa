#!/bin/bash -x

PREPDIR=/tmp

packagename="ethereum"

dist="precise"
srcdir=$1
version=$2
changelogmsg=$3

# Prepare version information and names
if [ "$version" == "" ]; then
	version="$(date +%Y%m%d)"
fi
archdir="$packagename-$version"
archfile="$archdir.tar.bz2"

echo Checking out...
rm -Rf $PREPDIR/cpp-ethereum
git clone $srcdir $PREPDIR/cpp-ethereum

opwd=`pwd`

cd $PREPDIR/cpp-ethereum

#temporary until files are removed from cpp-ethereum repo
rm -Rf debian
rm package.sh
rm release.sh

cp -r $opwd/debian .

echo Processing changelog...
debchange -v $version -p "$changelogmsg" -D "$dist"

echo Renaming directory...
cd .
opwd=`pwd`
cd ..
rm -rf $archdir
mv $opwd $archdir

echo Creating archive...
tar c $archdir --exclude-vcs --exclude-backups --exclude=debian | bzip2 -- > $archfile

[[ ! "$version" == "" ]] && ln -sf $archfile "${packagename}_$version.orig.tar.bz2"

echo Packaging...
cd "$archdir"

set -e
rm -f "../${packagename}_*_source.changes"
debuild -S -sa

cd ..
dput -f ppa:markobarko/ethereum "${packagename}_${version}_source.changes"

echo Cleaning up...
rm -rf $PREPDIR/$archdir
mv $PREPDIR/$archfile ~

echo Done.
