[![CircleCI](https://dl.circleci.com/status-badge/img/gh/giantswarm/aws-ebs-csi-driver-app/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/giantswarm/aws-ebs-csi-driver-app/tree/main)

# aws-ebs-csi-driver

Giant Swarm offers a aws-ebs-csi-driver app which is installed in workload clusters by default.

Here, we define the aws-ebs-csi-driver chart with its templates and default configuration.

## Build

Use `make build` to build the chart, there are additional steps to make sure everything is in place.

The snapshotter is located in a repo that uses Kustomize and we use a custom script to include all the resources inside the Helm template.

## Credit

* https://github.com/kubernetes-sigs/aws-ebs-csi-driver
