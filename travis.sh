#!/bin/bash

if [ "$TRAVIS_BRANCH" != "master" -o "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Not on master, aborting"
  exit 0
fi

if [ "$TRAVIS_REPO_SLUG" != "keneanung/TestRepository" ]; then
  echo "Not on main repo, aborting"
  exit 0
fi

cd ..
git clone --quiet --branch=gh-pages "https://keneanung:${GH_TOKEN}@github.com/keneanung/TestRepository.git" gh-pages 

cd gh-pages/downloads
cp "$TRAVIS_BUILD_DIR/mudlet-mapper.xml" .

datePart=$(date +"%y.%-m")
lastDatePart=$(echo "$(cat version 3> /dev/null)" | grep -o "^[0-9]*\.[0-9]*")
if [ "$lastDatePart" = "$datePart" ]; then
  versionPart=$(($(cat version | grep -o "[0-9]*$") + 1))
else
  versionPart=1
fi
version="$datePart.$versionPart"
sed -rbe 's/local newversion = &quot;developer&quot;/local newversion = \&quot;'$version'\&quot;/g' mudlet-mapper.xml > mudlet-mapper.xml.tmp && mv mudlet-mapper.xml.tmp mudlet-mapper.xml

git config user.email "travis@travis-ci.org"
git config user.name "Travis"

git commit -m"Release new version" .

git push
