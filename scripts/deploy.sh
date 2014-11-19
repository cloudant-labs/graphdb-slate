#!/bin/bash
if [ -z "$1" ]
then
  DB="slate"
else
  DB="$1"
fi

if [ -z "$2" ]
then
  URl=''
else
  URL="$2"
fi

python scripts/upload_documentation_as_docs.py "$DB"
couchapp push couchapp "${URL}${DB}"
