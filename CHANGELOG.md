# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.4.0] - 2026-01-22

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

## [3.3.0] - 2025-10-22

### Changed

- Chart: Sync to upstream. ([#338](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/338))
  - Chart: Update AWS EBS CSI Driver from v1.41.0 to v1.51.0.
  - Chart: ⚠️ URGENT: XFS Compatibility Issue - Newly formatted XFS volumes may fail to mount on nodes with older kernels (Amazon Linux 2). Use `node.legacyXFS: true` as workaround.
  - Chart: ⚠️ URGENT: Controller Health Checks - Controller now performs AWS API dry-run checks. Ensure proper IAM permissions and network connectivity.
  - Chart: ⚠️ URGENT: StorageClass Parameter Deprecation - `blockExpress` parameter is deprecated for `io2` volumes (now always uses 256,000 IOPS cap).
  - Chart: Add support for creating instant, point-in-time copies of EBS volumes within the same Availability Zone.
  - Chart: Add `debugLogs` parameter for maximum verbosity logging and debugging.
  - Chart: Add `metadataSources` configuration option for node metadata handling.
  - Chart: Add `disableMutation` parameter for service account mutation control.
  - Chart: Add support for updating node's max attachable volume count via `MutableCSINodeAllocatableCount` feature gate (Kubernetes 1.33+).
  - Chart: Update dependencies including AWS SDK, Prometheus, and various Go modules.
  - Chart: Add missing `enablePrometheusAnnotations` values for controller and node components.
  - Chart: Update sidecar container versions:
    - csi-provisioner: v5.2.0 → v5.3.0
    - csi-attacher: v4.8.1 → v4.9.0
    - csi-snapshotter: v8.2.1 → v8.3.0
    - livenessprobe: v2.14.0 → v2.16.0
    - csi-resizer: v1.13.2 → v1.14.0
    - csi-node-driver-registrar: v2.13.0 → v2.14.0
    - volume-modifier-for-k8s: v0.5.1 → v0.8.0

## [3.2.0] - 2025-10-07

### Changed

- Configure `gsoci.azurecr.io` as the default container image registry.

## [3.1.0] - 2025-09-17

### Changed

- Set default `updateStrategy.rollingUpdate.maxUnavailable` to 25% in `DaemonSet` to speed up rolling update.

## [3.0.5] - 2025-03-18

### Changed

- Chart: Update `snapshot-controller` to v8.2.1. ([#283](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/283))

## [3.0.4] - 2025-03-17

### Changed

- Chart: Sync to upstream. ([#264](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/264))

## [3.0.3] - 2025-02-25

### Changed

- Chart: Sync to upstream. ([#255](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/255))
  - Chart: Fix proxy settings.

## [3.0.2] - 2025-02-25

### Added

- Chart: Sync to upstream. ([#253](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/253))
  - Chart: Add FIPS endpoint support.
  - Chart: Add SELinux support.

### Changed

- Chart: Sync to upstream. ([#253](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/253))
  - Chart: Consume `global.image.registry`.
  - Chart: Fix IRSA annotation rendering.
  - Chart: Bump images.

## [3.0.1] - 2025-02-19

### Added

- Repository: Some chores. ([#235](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/235))
  - Repository: Add `Makefile.custom.mk`.
- Chart: Add `snapshot-controller` NetworkPolicy. ([#246](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/246))
  - Kustomization: Add `snapshot-controller` NetworkPolicy.

### Changed

- Harden security context for controller and node.
- Repository: Some chores. ([#235](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/235))
  - ABS: Rework `main.yaml`.
  - CircleCI: Rework `config.yml`.
  - Repository: Rework `README.md`.
  - Repository: Move `.gitignore` & `kustomization-snapshotter.yaml` to `vendor/external-snapshotter/`.
  - Chart: Rework `.kube-linter.yaml`.
  - Vendir: Rework `vendir.yml`.
  - Chart: Rework `Chart.yaml`.
  - Chart: Revert image to v1.37.0.
  - Renovate: Ignore `values.yaml`.
- Chart: Sync to upstream. ([#243](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/243))
  - Chart: Reorder labels.
  - Chart: Fix network policies.
- Chart: Add `snapshot-controller` NetworkPolicy. ([#246](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/246))
  - Vendir: Sync to `vendor/external-snapshotter/upstream`.
  - Kustomization: Set namespace.
  - Kustomization: Extend common labels.
  - Kustomization: Extract CRD patches.
  - Kustomization: Extract service account patches.
  - Kustomization: Extract deployment patches.

### Removed

- Repository: Some chores. ([#235](https://github.com/giantswarm/aws-ebs-csi-driver-app/pull/235))
  - Repository: Remove `.nancy-ignore`.
  - Chart: Remove pod `securityContext` from `external-snapshotter`.
  - Chart: Remove `.helmignore`.
  - Chart: Remove `CHANGELOG.md`.

## [3.0.0] - 2024-12-13

### Changed

- Change to use ImagePullPolicy as specified via values.
- Upgrade to release v1.37.0
- Enable Volume Snapshotter by default
- Switch to Helm managed CRDs

## [2.30.1] - 2024-04-11

### Fixed

- Disable PSPs for CRD job when `podSecurityStandards` are enforced.

## [2.30.0] - 2024-04-02

### Removed

- Remove unused service for controller.
- Add `Port` definition for metrics port in controller.

## [2.29.0] - 2024-04-02

### Removed

- Remove legacy monitoring labels.

## [2.28.1] - 2023-12-20

### Changed

- Configure `gsoci.azurecr.io` as the default container image registry.

## [2.28.0] - 2023-11-03

### Added

- Add a job that removes a gp2 storage class for EKS.

## [2.27.0] - 2023-10-26

### Fixed

- Fix RBAC issue with snapshots.

### Changed

- Upgraded all components to latest release.

## [2.26.0] - 2023-10-18

### Added

- Add `global.podSecurityStandards.enforced` value for PSS migration.

## [2.25.0] - 2023-08-10

### Changed

- Updated ebs-csi-driver to `v1.21.0` and updated sidecar images.

## [2.24.0] - 2023-06-12

### Changed

- Always install the VPA CR if `verticalPodAutoscaler.enabled` is true, no matter if the VPA CRD is present or not.

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

[Unreleased]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.4.0...HEAD
[3.4.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.0.1...v3.4.0
[4.0.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.3.0...v4.0.0
[3.3.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.0.5...v3.1.0
[3.0.5]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.0.4...v3.0.5
[3.0.4]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.0.3...v3.0.4
[3.0.3]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.0.2...v3.0.3
[3.0.2]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.0.1...v3.0.2
[3.0.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v3.0.0...v3.0.1
[3.0.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.30.1...v3.0.0
[2.30.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.30.0...v2.30.1
[2.30.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.29.0...v2.30.0
[2.29.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.28.1...v2.29.0
[2.28.1]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.28.0...v2.28.1
[2.28.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.27.0...v2.28.0
[2.27.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.26.0...v2.27.0
[2.26.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.25.0...v2.26.0
[2.25.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.24.0...v2.25.0
[2.24.0]: https://github.com/giantswarm/aws-ebs-csi-driver-app/compare/v2.23.0...v2.24.0
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
