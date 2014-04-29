#!/bin/bash
if [ -z $1 ]
then
  DEST='api-ref'
else
  DEST=$1
fi

couchapp push couchapp $DEST
