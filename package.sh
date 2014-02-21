#!/bin/bash 

packagename=$1
srcdir=$2
dist=$3
changelogmsg=$4
version=$5
repo=$6

if [ "$repo" == "" ]; then
	repo="markobarko/ethereum"
fi

# Prepare version information and names
if [ "$version" == "" ]; then
	version="$(date +%Y%m%d)"
fi

srcversion=${version%-*}
version=$version~${dist}1

echo "Package Name: $packagename"
echo "Source Directory: $srcdir"
echo "Distribution: $dist"
echo "Change Log Message: $changelogmsg"
echo "Source Version: $srcversion"
echo "Package Version: $version"
echo "Target PPA: $repo"

echo "Are these settings correct?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

PREPDIR=`mktemp -d`
opwd=`pwd`
cd $PREPDIR

#prepare orig archive 
archfile="${packagename}_${srcversion}.orig.tar.bz2"
archdir="$packagename-$version-$dist"

if [ -f $opwd/$packagename/$archfile ]; then
	echo "Using existing $archfile..."
	cp $opwd/$packagename/$archfile .

	mkdir origsrc
	tar xjf $archfile -C origsrc
else
	echo "Creating $archfile..."
	cp -r $srcdir origsrc
	cd origsrc

	tar cjf ../$archfile --exclude-vcs --exclude-backups --exclude=debian .
	cd ..

	cp $archfile $opwd/$packagename
fi

#prepare debian package
cp -r origsrc $archdir
cp -r "$opwd/$packagename/debian" $archdir

cd $archdir
debchange -v "$version" -p "$changelogmsg" -D "$dist"
debuild -S -sa

finalversion=`dpkg-parsechangelog | sed -n 's/^Version: //p'`
dput -f ppa:$repo "../${packagename}_${finalversion}_source.changes"
