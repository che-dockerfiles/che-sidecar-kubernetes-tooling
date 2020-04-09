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
    USERNAME=`cat /tmp/username`
    PLUGIN_IMAGE_ID=`buildah images -q quay.io/$USERNAME/che-sidecar-kubernetes-tooling`
    echo 'The last built image ID is :' $PLUGIN_IMAGE_ID
    PLUGIN_IMAGE=quay.io/$USERNAME/che-sidecar-kubernetes-tooling:dev
    echo 'Writing plugin image to a file in temp...'
    echo $PLUGIN_IMAGE > /tmp/plugin_image
    echo 'Pushing image' $PLUGIN_IMAGE
    buildah push $PLUGIN_IMAGE_ID docker://$PLUGIN_IMAGE
    echo 'Done'
else
    echo 'The first, you need to login and build the image'
fi
