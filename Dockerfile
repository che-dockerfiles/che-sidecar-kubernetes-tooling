# Copyright (c) 2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM quay.io/buildah/stable:v1.14.8

ENV KUBECTL_VERSION="v1.17.3" \
    HELM_VERSION="v3.1.1" \
    HOME="/home/theia"

ADD etc/storage.conf ${HOME}/.config/containers/storage.conf
ADD etc/containers.conf ${HOME}/.config/containers/containers.conf
ADD etc/subuid /etc/subuid
ADD etc/subgid /etc/subgid

RUN mkdir /projects && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done && \
    # buildah login requires writing to /run
    chgrp -R 0 /run && chmod -R g+rwX /run && \
    #Set the platform architecture
    export ARCH="$(uname -m)" && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; fi && \
    curl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -o /usr/local/bin/kubectl && \
    curl -o- -L https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz | tar xvz -C /usr/local/bin --strip 1 && \
    chmod +x /usr/local/bin/kubectl /usr/local/bin/helm && \
    # 'which' utility is used by VS Code Kubernetes extension to find the binaries, e.g. 'kubectl'
    dnf install -y which nodejs && \
    mkdir -p /var/tmp/containers/runtime && \
    chmod -R g+rwX /var/tmp/containers

ENV XDG_RUNTIME_DIR /var/tmp/containers/runtime

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
