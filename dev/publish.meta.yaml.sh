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
    echo 'Downloading template for plugin meta.yaml...'
    curl -o /tmp/plugin-template.meta.yaml https://raw.githubusercontent.com/vitaliy-guliy/che-sidecar-kubernetes-tooling/dev/dev/plugin-template.meta.yaml

    echo 'Generating plugin meta.yaml...'
    PLUGIN_IMAGE=`cat /tmp/plugin_image`
    PLUGIN_META_YAML=`node -pe "JSON.stringify(require('fs').readFileSync('/tmp/plugin-template.meta.yaml').toString().replace(/PLUGIN_IMAGE/g, '$PLUGIN_IMAGE'))"`

    read -p "GitHub login: " GITHUB_LOGIN
    read -s -p "GitHub password: " GITHUB_PASSWORD

    echo 'Pushing plugin meta.yaml to gist...'
    POST_DATA='{"public":true,"files":{"plugin.meta.yaml":{"content":'$PLUGIN_META_YAML'}}}'
    CURL_COMMAND=`echo "curl -X POST -d '"$POST_DATA"' -u "$GITHUB_LOGIN:$GITHUB_PASSWORD" https://api.github.com/gists > /tmp/plugin.gist.json"`
    eval $CURL_COMMAND

    PLUGIN_GIST_URL=`node -pe "JSON.parse(require('fs').readFileSync('/tmp/plugin.gist.json').toString()).files['plugin.meta.yaml'].raw_url"`
    echo 'Plugin gist URL' $PLUGIN_GIST_URL
    echo $PLUGIN_GIST_URL > /tmp/plugin.gist.url

    echo 'Done'
else
    echo 'The first, you need to login and build the image'
fi
