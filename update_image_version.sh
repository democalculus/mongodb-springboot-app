#!/bin/bash

sed -i "s#image_version_update#${imageVersion}#g" mss-us-east-db-prod.yml
cat mss-us-east-db-prod.yml |grep  'eagunuworld'
