# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM quay.io/eclipse/che-container-tools:1.0.0-36dcd2a

ADD etc/storage.conf ${HOME}/.config/containers/storage.conf
ADD etc/containers.conf ${HOME}/.config/containers/containers.conf
ADD etc/subuid /etc/subuid
ADD etc/subgid /etc/subgid

# buildah login requires writing to /run
RUN chgrp -R 0 /run && chmod -R g+rwX /run && \
    # 'which' utility is used by VS Code Kubernetes extension to find the binaries, e.g. 'kubectl'
    dnf install -y which nodejs && \
    mkdir -p /var/tmp/containers/runtime && \
    chmod -R g+rwX /var/tmp/containers

ENV XDG_RUNTIME_DIR /var/tmp/containers/runtime
