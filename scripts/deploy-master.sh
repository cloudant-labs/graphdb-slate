#!/bin/bash

BRANCH=master

if [[ "$TRAVIS_BRANCH" == "$BRANCH" ]] && [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
then
  if [ -z $1 ]
  then
    echo "No USERNAME provided. Skipping..."
  else
    python scripts/upload_documentation_as_docs.py
    couchapp push couchapp https://$1:$2@garbados.cloudant.com/api-ref
  fi
else
  echo "$TRAVIS_BRANCH is not $BRANCH, or this is a pull request; not deploying."
fi
