# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.1] - 2021-08-18

### Fixed

- Enable permissions for ebs volume resizing by default.

## [2.3.0] - 2021-08-03

### Changed

- Bump aws-ebs-csi-driver version to `v1.2.0`

## [2.2.0] - 2021-07-09

### Added

- CRD for snapshot-controller.

### Changed

- Update aws-ebs-csi-driver to v1.1.1.
- Reduce default log level to 2.
- Default volume resizing.

## [2.1.0] - 2021-06-16

### Added

- Add pod annotations and labels to snapshot-controller.

### Changed

- Update aws-ebs-csi-driver to v1.1.0.
- Rename file statefulset to snapshot-controller.

## [2.0.0] - 2021-05-04

### Changed

- Update aws-ebs-csi-driver to v1.0.0.

## [1.8.1] - 2021-04-06

### Changed

- Update aws-ebs-csi-driver to v0.10.0.
- Update csi-provisioner v2.1.1.
- Update snapshot-controller v3.0.3.

## [1.7.1] - 2021-02-19

## [1.7.0] - 2021-02-17

### Changed

- Rename storage class to `gp3` and set it as default.

## [1.6.0] - 2021-02-11

### Changed

- Enable EBS volume limit by default.
- Updated image aws-ebs-csi-volume-limiter 0.1.0.

## [1.5.0] - 2021-02-10

### Added

- Optional EBS volume limit.

## [1.4.0] - 2021-02-05

### Changes

- Adjust RBAC permissions for attaching.
- Update ebs-csi-driver to [v0.9.0](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/CHANGELOG-0.x.md#v090)

## [1.3.0] - 2021-02-01

## [1.2.0] - 2021-01-11

### Changes

- Update CSI images to align with upstream.
  - aws-ebs-csi-driver v0.8.1
  - csi-provisioner v2.1.0
  - csi-attacher v3.1.0
  - csi-snapshotter v3.0.3
  - csi-resizer v1.1.0
  - livenessprobe v2.2.0
  - csi-node-driver-registrar v2.1.0

## [1.1.0] - 2020-12-17

## [1.0.0] - 2020-12-02

## [0.0.13] - 2020-12-01

## [0.0.12] - 2020-12-01

## [0.0.11] - 2020-12-01

## [0.0.10] - 2020-11-30

## [0.0.9] - 2020-11-30

## [0.0.8] - 2020-11-27

## [0.0.7] - 2020-11-27

## [0.0.6] - 2020-11-26

## [0.0.5] - 2020-11-26

## [0.0.4] - 2020-11-25

## [0.0.3] - 2020-11-25

## [0.0.2] - 2020-11-25

## [0.0.1] - 2020-11-24

[Unreleased]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.3.1...HEAD
[2.3.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.8.1...v2.0.0
[1.8.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.7.1...v1.8.1
[1.7.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.13...v1.0.0
[0.0.13]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.12...v0.0.13
[0.0.12]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.11...v0.0.12
[0.0.11]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.10...v0.0.11
[0.0.10]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/releases/tag/v0.0.1
