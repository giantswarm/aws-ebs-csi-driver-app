# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.23.0] - 2023-05-30

### Changed

- Make sure `node` doesn't run on control plane nodes.

## [2.22.0] - 2023-05-18

### Changed

- Bump `snapshot-controller` to 6.2.1.
- Align `snapthot-controller` deployment to upstream.
- Add PDB for `snapthot-controller`.

## [2.21.1] - 2023-04-26

### Fixed

- Use `string` type for the proxy parameters on the `values.schema.json` file.

## [2.21.0] - 2023-04-03

### Added

- Add cilium network policies.

## [2.20.1] - 2023-03-22

### Added

- Add `node-role.kubernetes.io/control-plane` to crd install jobs toleration.

## [2.20.0] - 2023-01-17

### Changed

- Updated ebs-csi-driver to `v1.15` and updated sidecar images.

## [2.19.1] - 2022-12-08

### Fixed

- Fixed image version of ebs-snapshotter.

## [2.19.0] - 2022-11-29

### Fixed

- Fix scraping monitoring port.

### Added

- Support for running behind a proxy.
  - `HTTP_PROXY`,`HTTPS_PROXY` and `NO_PROXY` are set as environment variables in `deployment/ebs-plugin` if defined in `values.yaml`.
- Support for using `cluster-apps-operator` specific `cluster.proxy` values.

## [2.18.0] - 2022-11-16

### Changed

- Update aws-ebs-csi-driver version to `v1.13.0`.

## [2.17.0] - 2022-11-03

### Changed

- Add short names for Volume Snapshot CRDs.
- Update aws-ebs-csi-driver version to `v1.12.1`.
- Update csi-snapshotter version to `v6.0.1`.
- Update csi-resizer version to `v1.4.0`.
- Update csi-node-driver-registrar version to `v2.5.1`.
- Update snapshot-controller version to `v6.1.1`.

## [2.16.1] - 2022-07-21

### Fixed

- Changing controller `httpEndpoint` to `8610` because of overlapping ports.

## [2.16.0] - 2022-07-12

### Changed

- Bump aws-ebs-csi-driver version to `v1.8.0`.

## [2.15.0] - 2022-07-04

### Changed

- Use `global.image.registry` as registry domain for all images.

## [2.14.0] - 2022-06-15

### Changed

- Remove `imagePullSecrets` from values.yaml
- Bump aws-ebs-csi-driver version to `v1.6.2`.

## [2.13.0] - 2022-04-25

## [2.12.0] - 2022-04-13

### Changed

- Revert `controller` to be a deployment.
- Allow specifying `nodeSelector` and `hostNetwork` for `controller` and `node`.

## [2.11.0] - 2022-04-11

### Changed

- Run `controller` as daemonset on all master nodes.
- Bump aws-ebs-csi-driver version to `v1.5.1`.

### Added

- Allow specifying `driverMode` for the `controller` component.

## [2.10.0] - 2022-04-08

### Added

- Also push to control-plane app catalog.

## [2.9.0] - 2022-03-22

### Added

- Add VerticalPodAutoscaler CR.

## [2.8.1] - 2022-02-02

### Fixed

- Use node selector according to control-plane and nodepool labels.

## [2.8.0] - 2021-12-14

### Changed

- Bump aws-ebs-csi-driver version to `v1.5.0`.
- Enable metrics.

## [2.7.1] - 2021-10-19

### Changed

- Update chart app version.

## [2.7.0] - 2021-10-14

### Changed

- Bump aws-ebs-csi-driver version to `v1.4.0`.
- Pre-Hook for snapshot CRDs.
- Use deployment for external-snapshot-controller.

## [2.6.1] - 2021-10-08

### Fixed

- Move CRD's to template.

## [2.6.0] - 2021-10-08

### Added

- Add common labels to allow helm operating on CRD's.

## [2.5.0] - 2021-10-08

### Changed

- Update CSI images to the latest version.

## [2.4.0] - 2021-10-08

### Changed

- Bump aws-ebs-csi-driver version to `v1.3.0`
- Change VolumeSnapshotter CRDs storage version from v1beta1 to v1.

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

[Unreleased]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.23.0...HEAD
[2.23.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.22.0...v2.23.0
[2.22.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.21.1...v2.22.0
[2.21.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.21.0...v2.21.1
[2.21.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.20.1...v2.21.0
[2.20.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.20.0...v2.20.1
[2.20.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.19.1...v2.20.0
[2.19.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.19.0...v2.19.1
[2.19.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.18.0...v2.19.0
[2.18.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.17.0...v2.18.0
[2.17.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.16.1...v2.17.0
[2.16.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.16.0...v2.16.1
[2.16.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.15.0...v2.16.0
[2.15.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.14.0...v2.15.0
[2.14.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.13.0...v2.14.0
[2.13.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.12.0...v2.13.0
[2.12.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.11.0...v2.12.0
[2.11.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.10.0...v2.11.0
[2.10.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.9.0...v2.10.0
[2.9.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.8.1...v2.9.0
[2.8.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.8.0...v2.8.1
[2.8.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.7.1...v2.8.0
[2.7.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.7.0...v2.7.1
[2.7.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.6.1...v2.7.0
[2.6.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.6.0...v2.6.1
[2.6.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.5.0...v2.6.0
[2.5.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.4.0...v2.5.0
[2.4.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.3.1...v2.4.0
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
