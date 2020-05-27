# che-sidecar-kubernetes-tooling

Eclipse Che Sidecar container for Kubernetes tooling

This sidecar image is used to run Che Plug-ins in dedicated containers

# Dockerfiles

The master branch contains the Dockerfile that builds the sidecar container for the latest version of the plugin.

Older versions of the Dockerfile for older plugin versions which are still supported will live on their own branch, i.e.: the Dockerfile which builds the sidecar container for the 1.2.0 version of the plugin will live on the 1.2.0 branch.

This repository uses an automatic GitHub Action which will build, tag, and push a container image on every push. In order to specify which version of the container is built, tagged, and pushed, be sure to edit the VERSION file with the correct version.

 - To update the Dockerfile for the latest version, make a PR against master
 - Ensure VERSION contains the correct version you wish to build
 - To update an older version of the sidecar container, open a PR against the branch for the version you wish to update
 
 Please note that documentation changes (i.e. to any .md file) will not result in a build.
 
 # Platforms
This repository supports multiple architecture builds. To add a platform, edit the PLATFORMS file and add your desired platform. Currently this plugin sidecar supports the following architectures:
 
 - linux/amd64


# Contributing

Contributing section is covered in [CONTRIBUTING.md](CONTRIBUTING.md)

