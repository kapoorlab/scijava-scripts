#!/bin/sh

# Script to print version properties for a given pom-scijava release.

# Examples:
# sj-version.sh 1.70
# sj-version.sh 1.70 1.74

version="$1"
diff="$2"

repo="http://maven.imagej.net/content/groups/public"

props() {
	if [ -e "$1" ]
	then
		# extract version properties from the given file path
		versions=$(cat "$1")
	else
		url="$repo/org/scijava/pom-scijava/$1/pom-scijava-$1.pom"
		versions=$(curl -s "$url")
		# assume argument is a version number of pom-scijava
	fi
	echo "$versions" | \
		grep '\.version>' | \
		sed -E -e 's/^				(.*)/\1 [DEV]/' | \
		sed -E -e 's/^	*<(.*)\.version>(.*)<\/.*\.version>/\1 = \2/' | \
		sort
}

if [ -z "$version" ]
then
	# try to extract version from pom.xml in this directory
	if [ -e pom.xml ]
	then
		version=$(grep -A 1 pom-scijava pom.xml | \
			grep '<version>' | \
			sed 's/<\/.*//' | \
			sed 's/.*>//')
	fi
fi

if [ -z "$version" ]
then
	echo "Usage: sj-version.sh version [version-to-diff]"
	exit 1
fi

if [ -n "$diff" ]
then
	# compare two versions
	props $version > $version.tmp
	props $diff > $diff.tmp
	diff -y $version.tmp $diff.tmp
	rm $version.tmp $diff.tmp
else
	# dump props for one version
	props $version
fi
