#!/bin/bash

PREPDIR=`mktemp -d`

packagename="libcryptoppeth"

srcdir=$1
version=$2
dist=$3
changelogmsg=$4

# Prepare version information and names
if [ "$version" == "" ]; then
	version="$(date +%Y%m%d)"
fi
if [ "$dist" == "" ]; then
	dist="saucy"
fi
archdir="$packagename-$version"
archfile="$archdir.tar.bz2"

echo Checking out...
cp -r $srcdir/* $PREPDIR
cp -r debian $PREPDIR

echo Processing changelog...
cd $PREPDIR
debchange -v $version -p "$changelogmsg" -D "$dist"

echo Renaming directory...
cd .
opwd=`pwd`
cd ..
rm -rf $archdir
mv $opwd $archdir

echo Creating archive...
tar c $archdir --exclude-vcs --exclude-backups --exclude=debian | bzip2 -- > $archfile

[[ ! "$version" == "" ]] && ln -sf $archfile "${packagename}_${version%-*}.orig.tar.bz2"

echo Packaging...
cd "$archdir"

set -e
rm -f "../${packagename}_*_source.changes"
debuild -S -sa

cd ..
dput -f ppa:markobarko/ethereum "${packagename}_${version}_source.changes"

echo Cleaning up...
rm -rf $PREPDIR

echo Done.
