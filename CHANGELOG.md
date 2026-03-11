# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Add `io.giantswarm.application.audience: all` annotation to publish the app to the customer Backstage catalog.
- Migrate chart metadata annotations to `io.giantswarm.application.*` format for both the app and bundle charts.

## [4.1.2] - 2026-03-09

### Changed

- Update ABS config to replace `.appVersion` in Chart.yaml with version detected by ABS.

### Fixed

- Use `.Chart.AppVersion` instead of `.Chart.Version` for OCIRepository tag.

## [4.1.1] - 2026-02-06

### Changed

- Refactor crossplane config data retrieval. Fail installation if the ConfigMap can't be found, otherwise the chart was creating invalid IAM roles.

## [4.1.0] - 2026-01-27

### Changed

- Change IAM role name for the ebs-csi-driver-controller, to differentiate it from the old one managed by the iam-operator.

## [4.0.3] - 2026-01-23

### Fixed

- Fix boolean type of the expansion

## [4.0.2] - 2026-01-22

### Fixed

- Allow volume expansion by default on gp3

## [4.0.1] - 2026-01-22

### Changed

- Remove dependency for the cloud-provider-aws in the aws-ebs-csi-driver HelmRelease. That dependency should be set in the bundle HelmRelease by the provider cluster chart

## [4.0.0] - 2026-01-21

### Added

- Introduce bundle chart architecture with Crossplane IAM resources.
  - Add `aws-ebs-csi-driver-app-bundle` chart that includes:
    - Crossplane IAM Role with EBS CSI driver permissions
    - Flux HelmRelease to deploy the workload cluster chart
    - ConfigMap for values passthrough
  - Bundle chart is installed on the management cluster and deploys the app chart to the workload cluster
  - IAM role uses OIDC federation (IRSA) and reads configuration from `<clusterID>-crossplane-config` ConfigMap
  - Both charts share the same version and are released together

### Changed

- Update CircleCI configuration to push both app and bundle charts
- Update README with bundle architecture documentation

[Unreleased]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.1.2...HEAD
[4.1.2]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.1.1...v4.1.2
[4.1.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.1.0...v4.1.1
[4.1.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.0.3...v4.1.0
[4.0.3]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.0.2...v4.0.3
[4.0.2]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.0.1...v4.0.2
[4.0.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.3.0...v4.0.0
