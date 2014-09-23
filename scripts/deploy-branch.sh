#!/bin/bash

<<<<<<< HEAD
BRANCH=testb

=======
>>>>>>> 94194fc... deploy any branch to docs-testb.cloudant.com/$branch
if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
then
  if [ -z "$1" ]
  then
    echo "No USERNAME provided. Skipping..."
  else
    python scripts/upload_documentation_as_docs.py "$TRAVIS_BRANCH"
    #deploy with db name == branch name
    couchapp push couchapp "https://$1:$2@docs-testb.cloudant.com/${TRAVIS_BRANCH}"
    #give everybody read access and docs-testb admin access
    curl -X PUT "https://$1:$2@docs-testb.cloudant.com/${TRAVIS_BRANCH}/_security" -d '{"_id":"_security","cloudant":{"nobody":["_reader"],"docs-testb":["_reader","_writer","_admin","_replicator"]}}'
  fi
else
  echo "this is a pull request; not deploying."
fi
