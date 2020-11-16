#!/bin/bash
set -e

git clone git-repo release-git-repo

pushd release-git-repo > /dev/null
	git fetch --tags --all
	last=$( git tag --list "v${MAJOR_VERSION}.${MINOR_VERSION}*"| sed -E "s/^.*${2}([0-9]+)$/\1/g" | sort -rn | head -n1 )
	next=$((last+1))
	releaseVersion=v${MAJOR_VERSION}.${MINOR_VERSION}.$next
	echo "Releasing $releaseVersion"
	git config user.name "Spring Buildmaster" > /dev/null
	git config user.email "buildmaster@springframework.org" > /dev/null
	git tag -a "v$releaseVersion" -m"Release v$releaseVersion" > /dev/null
popd > /dev/null
