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

    buildah bud -t quay.io/$USERNAME/che-sidecar-kubernetes-tooling:dev .
    echo 'Image built'

    buildah images
    echo 'Done'
else
    echo 'You need to login the first'
fi
