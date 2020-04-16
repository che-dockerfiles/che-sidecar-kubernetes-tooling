Contribute to Kubernetes tooling VS Code extension and to Eclipse Che Sidecar container
================

Table of contents

 - [Introduction](#introduction)
 - [Devfile](#devfile)
 - [Contribute to VS Code Kubernetes tooling extension](#)
 - [Eclipse Che Sidecar container for Kubernetes plugin](#)
 
## Introduction

There are 2 contribution points:
- VS Code [Kubernetes tooling extension](https://github.com/Azure/vscode-kubernetes-tools)
- [Eclipse Che Sidecar container](https://github.com/che-dockerfiles/che-sidecar-kubernetes-tooling) for [Kubernetes plugin](https://github.com/eclipse/che-plugin-registry/tree/master/v3/plugins/ms-kubernetes-tools/vscode-kubernetes-tools)

For contribution to Kubernetes tooling VS Code extension, you don't need to rebuild the container image to code, build and test.
It is possible to create a Che workspace that would setup all the containers to build and run the extension. The workspace will have a dedicated container with [buildah](https://github.com/containers/buildah) tool, which you can use to build the docker image containing the Kubernetes tooling.
You will find here a [devfile](devfile.yaml) that will help you to setup the environment.

## Devfile

The devfile could be run on any Che instances. But given the memory requirements of about 8 gigabytes, and some limitations when using the buildah, the devfile has been thoroughly tested only on local Che deployment running in minikube.
The devfile could be launched through a factory or [chectl](https://github.com/che-incubator/chectl) cli. It's also possible to apply the devfile content when creating a workspace in the dashboard.

The newly created workspace will have the following containers:

- theia-ide
- che-dev
- buildah-dev

**Theia-Ide** is used as default container where your Che-Theia editor is running. We also use this container to run another instance of Che-Theia to test the Kubernetes extension. To be ensure that memory is enough for running of two instances of Che-Thea with full set of plugins, the memory limitation for this container is set to 3 gigabytes.

**Che-Dev** container is used to build the Kubernetes tooling extension. To run it in **buildah-dev** container, the [eclipse-che-theia-plugin-remote](https://github.com/eclipse/che-theia/tree/master/extensions/eclipse-che-theia-plugin-remote) extension of [che-theia](https://github.com/eclipse/che-theia) is used. Since this extension is not published to [npmjs](https://www.npmjs.com/search?q=%40eclipse-che), we have to build it from sources. Memory limitation for che-dev container is set to 2 gigabytes.

The third, **buildah-dev** is needed to run Kubernetes tooloing extension as a remote plugin and to build sidecar docker image for Eclipse Che Kubernetes plugin. It should be emphasized that the target directory with build images is not persisted, will be lost after restarting the workspace. You need to push your images to [docker.io](docker.io) or [quay.io](quay.io) before leaving the workspace.

After startup and finishing cloning of projects, your will have
- che-sidecar-kubernetes-tooling
- che-theia
- vscode-kubernetes-tools


## Contribute to VS Code Kubernetes tooling extension

The VS Code [Kubernetes tooling extension](https://github.com/Azure/vscode-kubernetes-tools) will be cloned to your workspace in `vscode-kubernetes-tools` directory.
You can easily create branch, code, commit and push your changes using using Che-Theia editor.

To create branch, commit and push your changes use Source Control view of Che-Theia or command line git by opening a terminal in `theia-ide` or `che-dev` container.

Tu build and run the extension you can use set of predefined commands.

### Install node dependencies

To install node dependencies for `vscode-kubernetes-tools`, click `'1.1 Kubernetes Plugin :: Install dependencies'` command in `MY WORKSPACE` view which on the right. It will run `npm install` command in `/projects/vscode-kubernetes-tools` directory iside `che-dev` container.

[che-dev]
```
$ cd /projects/vscode-kubernetes-tools
$ npm install
```

### Package the extension

To pack your extension to a `.vsix` file use `'1.2 Kubernetes Plugin :: Package'` command. It will run [vscode etxnension packager](https://github.com/microsoft/vscode-vsce) in `che-dev` container. An apropriate `vscode-kubernetes-tools-{version}.vsix` will appear in the project directory when success.

[che-dev]
```
$ cd /projects/vscode-kubernetes-tools
$ vsce package
```

### Build Che-Theia remote plugin connector

[Che-Theia](https://github.com/eclipse/che-theia) repository will be cloned to your workspace on startup.
I contains a special [eclipse-che-theia-plugin-remote](https://github.com/eclipse/che-theia/tree/master/extensions/eclipse-che-theia-plugin-remote) extension, which is used to launch VS Code extensions as a remote plugin by running it in another container, different from `theia-ide`. To build [eclipse-che-theia-plugin-remote](https://github.com/eclipse/che-theia/tree/master/extensions/eclipse-che-theia-plugin-remote) extension use `'1.3 Che-Theia plugin-remote :: Compile'` command. It will run the following inside `che-dev` container.

[che-dev]
```
$ cd /projects/che-theia/extensions/eclipse-che-theia-plugin-remote
$ yarn
```

### Run Che-Theia + VS Code Kubernetes tooling extension

The `buildah-dev` container is used to run the kubernetes tooling extension. Projects (`/projects`) directory is shared between containers, and the built `eclipse-che-theia-plugin-remote` is accesisble from `buildah-dev`.
To run the extension use `'2.1 Run :: Remote Kubernetes extension'` command. The command will configure necessary environment variables, download the latest 0.7.2 release of [redhat.vscode-yaml](https://github.com/redhat-developer/vscode-yaml/releases) extension on which the Kubernetes tooling depends, and will run `eclipse-che-theia-plugin-remote`.

[buildah-dev]
```
$ mkdir -p /tmp/vscode-plugins
$ cd /tmp/vscode-plugins
$ curl -O -L https://github.com/redhat-developer/vscode-yaml/releases/download/0.7.2/redhat.vscode-yaml-0.7.2.vsix
$ export THEIA_PLUGIN_ENDPOINT_DISCOVERY_PORT='2504'
$ export THEIA_PLUGINS='local-dir:///tmp/vscode-plugins,local-dir:///projects/vscode-kubernetes-tools'
$ node /projects/che-theia/extensions/eclipse-che-theia-plugin-remote/lib/node/plugin-remote.js
```

To run Che-Theia instance in `theia-ide` container run `'2.2 Run :: Che-Theia'` command. This command will set necessary environment variables and will run Che-Theia on different port. On startup, Che-Theia will find and bind the `Kubernetes tooling` and `redhat.vscode-yaml` extensions.

[theia-ide]
```
$ cd /home/theia
$ mkdir -p /tmp/theiadev_projects
$ export CHE_PROJECTS_ROOT=/tmp/theiadev_projects
$ export THEIA_PLUGIN_ENDPOINT_DISCOVERY_PORT='2504'
$ node src-gen/backend/main.js /tmp/theiadev_projects --hostname=0.0.0.0 --port=3130
```

Click on `theia-ide/theia-dev` tree node in `MY WORKSPACE` view to open a new browser window with a separete Che-Theia instance.
To stop the command execution, focus the command output view and click `Ctrl+C`.

## Eclipse Che Sidecar container for Kubernetes plugin

On startup, the repository [che-sidecar-kubernetes-tooling](https://github.com/che-dockerfiles/che-sidecar-kubernetes-tooling) will be cloned to your workspace. The project describes a docker image to run Kubernetes tooling extension.
You can easily build the image inside `buildah-dev` container and push the omage to your account on [quay.io](quay.io).

### Login to quay.io

The first you need to login to [quay.io](quay.io) repository. For that you can use `'3.1 Login to quay.io'` command in `MY WORKSPACE` view.
It will ask for the user name, will save it to a temporary file and then will login to [quay.io](quay.io).
Storing to the file is needed to avoid asking the user name when building and when pushing your image. 

The command will run the following in `buildah-dev` container.

[buildah-dev]
```
$ cd /projects/che-sidecar-kubernetes-tooling
$ read -p "Username: " USERNAME
$ echo $USERNAME > /tmp/username
$ buildah login --username $USERNAME quay.io
```

### Build the image

To build the image use `'3.2 Build the image'`. It will switch to `/projects/che-sidecar-kubernetes-tooling` directory and build the image using a Dockerfile. When finish, the list of available images will be shown.

[buildah-dev]
```
$ cd /projects/che-sidecar-kubernetes-tooling
$ USERNAME=`cat /tmp/username`
$ buildah bud -t quay.io/$USERNAME/che-sidecar-kubernetes-tooling:dev .
$ buildah images
```

### Push to quay.io

Use `'3.3 Push to quay.io'` command to push the image to your account on [quay.io](quay.io). The command will run the following sequence of commands in `buildah-dev` container.

[buildah-dev]
```
$ cd /projects/che-sidecar-kubernetes-tooling
$ USERNAME=`cat /tmp/username`
$ PLUGIN_IMAGE_ID=`buildah images -q quay.io/$USERNAME/che-sidecar-kubernetes-tooling`
$ PLUGIN_IMAGE=quay.io/$USERNAME/che-sidecar-kubernetes-tooling:dev
$ buildah push $PLUGIN_IMAGE_ID docker://$PLUGIN_IMAGE
```

The memory limitation for `buildah-dev` container is set to 3 gigabytes, which should be enough for mostly cases. In a case you cannot build the image due to lack of the memory, you can easily add more by editing the devfile in the dashboard with the following restarting the workspace.
