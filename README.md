[![CircleCI](https://dl.circleci.com/status-badge/img/gh/giantswarm/aws-ebs-csi-driver-app/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/giantswarm/aws-ebs-csi-driver-app/tree/main)

# aws-ebs-csi-driver

Giant Swarm offers an `aws-ebs-csi-driver-app-bundle` Managed App which can be installed in tenant clusters.

Here we define the `aws-ebs-csi-driver-app-bundle`, `aws-ebs-csi-driver-app` charts with their templates and default configuration.

## Architecture

This repository contains two Helm charts:

- `helm/aws-ebs-csi-driver-app-bundle/`: Main chart installed on the management cluster, contains the workload cluster chart and the required AWS IAM role.
- `helm/aws-ebs-csi-driver-app/`: Workload cluster chart that contains the actual EBS CSI driver setup.

Users only need to install the bundle chart on the management cluster, which in turn will deploy the workload cluster chart.

## Installation

Install the chart on the management cluster using an App CR:

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  name: coyote-aws-ebs-csi-driver-app-bundle
  namespace: org-acme
spec:
  catalog: default
  config:
    configMap:
      name: coyote-cluster-values
      namespace: org-acme
  kubeConfig:
    inCluster: true
  name: aws-ebs-csi-driver-app-bundle
  namespace: org-acme
  version: 3.3.0
```

## Build

Use `make build` to build the chart, there are additional steps to make sure everything is in place.

The snapshotter is located in a repo that uses Kustomize and we use a custom script to include all the resources inside the Helm template.

## Credit

* https://github.com/kubernetes-sigs/aws-ebs-csi-driver
