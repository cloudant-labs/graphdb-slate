#!/bin/bash
if [ -z $1 ]
then
  echo 'usage: deploy.sh DESTINATION'
else
  couchapp push couchapp "$1"
fi


