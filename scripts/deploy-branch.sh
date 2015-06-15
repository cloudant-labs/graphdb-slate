#!/bin/bash

# TODO: change
HOST='docs-testb.cloudant.com'

if [[ "$TRAVIS_PULL_REQUEST" == "false" ]]
then
  if [ -z "$1" ]
  then
    echo "No USERNAME provided. Skipping..."
  else
    rm -rf tmp
    mkdir tmp
    echo curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}" -X PUT
    curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}" -X PUT
    python scripts/upload_documentation_as_docs.py "$TRAVIS_BRANCH"
    for file in `ls tmp`; do
			rev=$(curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}/${file}" | jq -r '._rev')
			if [ $rev = null ]; then
			  echo curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}/${file}" -X PUT -H 'Content-Type: application/json' -d "@tmp/${file}"
				curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}/${file}" -X PUT -H 'Content-Type: application/json' -d "@tmp/${file}"
			else
			  echo curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}/${file}?rev=${rev}" -X PUT -H 'Content-Type: application/json' -d "@tmp/${file}"
				curl "https://$USERNAME:$PASSWORD@${HOST}/${TRAVIS_BRANCH}/${file}?rev=${rev}" -X PUT -H 'Content-Type: application/json' -d "@tmp/${file}"
			fi
		done

    #deploy with db name == branch name
    couchapp push couchapp "https://$1:$2@${HOST}/${TRAVIS_BRANCH}"
    #TODO give authorized people read access, remove nobody from default read access
    security='
      {
        "cloudant": {
		      "nobody": ["_reader"]
		    }
		  }'
    if [ "${TRAVIS_BRANCH}" = "content-review" ]; then
      security='
        {
          "cloudant": {
            "nobody":["_reader"]
          }
        }'
    fi
    curl -X PUT "https://$1:$2@${HOST}/${TRAVIS_BRANCH}/_security" -d "${security}"
  fi
else
  echo "this is a pull request; not deploying."
fi
