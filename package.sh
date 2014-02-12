#!/bin/bash 

packagename=$1
srcdir=$2
dist=$3
srcversion=$4

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
archdir="$packagename-$srcversion"
cp -r origsrc $archdir
cp -r "$opwd/$packagename/debian" $archdir

cd $archdir
debchange -i -p "$changelogmsg" -D "$dist"
debuild -S -sa

#dput -f ppa:markobarko/ethereum "${packagename}_${srcversion}_source.changes"

echo Cleaning up...
#rm -rf $PREPDIR

echo Done.
