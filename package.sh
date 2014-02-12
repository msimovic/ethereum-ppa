#!/bin/bash 

packagename=$1
srcdir=$2
dist=$3
changelogmsg=$4
srcversion=$5

# Prepare version information and names
if [ "$srcversion" == "" ]; then
	srcversion="$(date +%Y%m%d)"
fi
archfile="${packagename}_${srcversion}.orig.tar.bz2"

PREPDIR=`mktemp -d`
opwd=`pwd`

cd $PREPDIR

#prepare orig archive 
cp -r $srcdir origsrc
cd origsrc
tar cjf ../$archfile --exclude-vcs --exclude-backups --exclude=debian .
cd ..

#prepare debian package
archdir="$packagename-$srcversion-$dist"
cp -r origsrc $archdir
cp -r "$opwd/$packagename/debian" $archdir

cd $archdir
debchange -v "$srcversion" -p "$changelogmsg" -D "$dist"
debuild -S -sa

finalversion=`dpkg-parsechangelog | sed -n 's/^Version: //p'`
dput -f ppa:markobarko/ethereum "../${packagename}_${finalversion}_source.changes"
