#!/bin/bash

sed -i "s#image_version_update#${imageVersion}#g" springboot_manifest.yml
cat springboot_manifest.yml |grep  'eagunuworld'
