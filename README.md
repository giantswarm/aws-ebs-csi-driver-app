[![CircleCI](https://circleci.com/gh/giantswarm/aws-ebs-csi-driver-app.svg?style=shield)](https://circleci.com/gh/giantswarm/aws-ebs-csi-driver-app)

# aws-ebs-csi-driver-app chart

Giant Swarm offers a aws-ebs-csi-driver Managed App which can be installed in tenant clusters.
Here we define the aws-ebs-csi-driver chart with its templates and default configuration.

## Build

Use `make build` to build the chart, there are additional steps to make sure eveything is in place.

The snapshotter is located on a repo that uses kustomize and we use a custom script to include all the resources inside the helm template.

## Credit

* https://github.com/kubernetes-sigs/aws-ebs-csi-driver
