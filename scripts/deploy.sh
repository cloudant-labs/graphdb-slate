#!/bin/bash
if [ -z "$1" ]
then
  echo 'no db specified'
  echo './deploy DB URL'
  exit
else
  DB="$1"
fi

if [ -z "$2" ]
then
  echo 'no base url specified'
  echo './deploy DB URL'
else
  URL="$2"
fi

python scripts/upload_documentation_as_docs.py "$DB"
couchapp push couchapp "${URL}${DB}"
