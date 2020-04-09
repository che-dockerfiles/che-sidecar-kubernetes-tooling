#!/bin/sh
#
# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# See: https://sipb.mit.edu/doc/safe-shell/

if [ -f "/tmp/username" ]; then
    echo 'Downloading template for devfile.yaml...'
    curl -o /tmp/devfile-template.yaml https://raw.githubusercontent.com/vitaliy-guliy/che-sidecar-kubernetes-tooling/dev/devfile-template.yaml

    echo 'Generating devfile.yaml...'
    PLUGIN_GIST_URL=`cat /tmp/plugin.gist.url`
    DEVFILE_YAML=`node -pe "JSON.stringify(require('fs').readFileSync('/tmp/devfile-template.yaml').toString().replace(/PLUGIN_GIST_URL/g, '$PLUGIN_GIST_URL'))"`

    read -p "GitHub login: " GITHUB_LOGIN
    read -s -p "GitHub password: " GITHUB_PASSWORD

    echo 'Pushing devfile.yaml to gist...'
    POST_DATA='{"public":true,"files":{"devfile.yaml":{"content":'$DEVFILE_YAML'}}}'
    CURL_COMMAND=`echo "curl -X POST -d '"$POST_DATA"' -u "$GITHUB_LOGIN:$GITHUB_PASSWORD" https://api.github.com/gists > /tmp/devfile.gist.json"`
    eval $CURL_COMMAND

    DEVFILE_RAW_URL=`node -pe "JSON.parse(require('fs').readFileSync('/tmp/devfile.gist.json').toString()).files['devfile.yaml'].raw_url"`
    echo 'Devfile.yaml URL' $DEVFILE_RAW_URL
    echo 'Done'
else
    echo 'The first, you need to login and build the image'
fi
