[![CircleCI](https://dl.circleci.com/status-badge/img/gh/giantswarm/aws-ebs-csi-driver-app/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/giantswarm/aws-ebs-csi-driver-app/tree/main)

# aws-ebs-csi-driver chart

Giant Swarm offers an `aws-ebs-csi-driver-bundle` Managed App which can be installed in tenant clusters.
Here we define the `aws-ebs-csi-driver-bundle` and `aws-ebs-csi-driver` charts with their templates and default configuration.

## Key terminology

| Term | Where it lives | What it does |
|------|---------------|--------------|
| **BUNDLE-ONLY** | Management cluster only | Never forwarded to workload chart. Examples: `clusterID`, `ociRepositoryUrl` |
| **UPSTREAM** | Workload cluster, under `upstream:` key | Routed to the unmodified upstream subchart. Controls the actual EBS CSI driver: images, controller/node settings, service accounts, storage classes, etc. |
| **EXTRAS** | Workload cluster, at top level (not under `upstream:`) | Consumed by GS extras templates: `networkPolicy`, `verticalPodAutoscaler`, `global.podSecurityStandards`, etc. |

## Architecture

```
Management Cluster                          Workload Cluster
┌──────────────────────────────────┐       ┌──────────────────────────────────┐
│  aws-ebs-csi-driver-bundle       │       │  aws-ebs-csi-driver (Flux)       │
│                                  │       │                                  │
│  ┌────────────┐                  │       │  ┌────────────────────────────┐  │
│  │ IAM Role   │ (Crossplane)     │       │  │ upstream subchart (alias)  │  │
│  └────────────┘                  │       │  │  - Deployment (controller) │  │
│  ┌────────────┐                  │       │  │  - DaemonSet (node)        │  │
│  │ ConfigMap   │─── values ──────┼──────>│  │  - RBAC, CSIDriver, etc.   │  │
│  └────────────┘  (workloadValues │       │  └────────────────────────────┘  │
│  ┌────────────┐   helper)        │       │  ┌────────────────────────────┐  │
│  │ OCIRepo +  │                  │       │  │ GS extras                  │  │
│  │ HelmRelease│──────────────────┼──────>│  │  - NetworkPolicy           │  │
│  └────────────┘                  │       │  │  - VPA                     │  │
│                                  │       │  │  - PSS exceptions          │  │
└──────────────────────────────────┘       │  │  - external-snapshotter    │  │
                                           │  └────────────────────────────┘  │
                                           └──────────────────────────────────┘
```

### Charts

| Chart | Location | Deployed to | Purpose |
|-------|----------|-------------|---------|
| `aws-ebs-csi-driver-bundle` | `helm/aws-ebs-csi-driver-bundle/` | Management cluster | Orchestrator. Creates IAM role (Crossplane), Flux resources (OCIRepository + HelmRelease), and a ConfigMap with computed values. |
| `aws-ebs-csi-driver` | `helm/aws-ebs-csi-driver/` | Workload cluster (via Flux) | Wraps the **unmodified** upstream chart as a Helm dependency (alias `upstream`) and adds GS-specific extras templates. |

### Value flow

1. User installs `aws-ebs-csi-driver-bundle` on the management cluster via an App CR.
2. The bundle `_helpers.tpl` runs the `giantswarm.workloadValues` helper which:
   - Reads the crossplane-config ConfigMap to obtain AWS account ID and OIDC domains.
   - Computes the IRSA role ARN and injects it into `controller.serviceAccount.annotations` (`giantswarm.setValues`).
   - Prepends `global.image.registry` as `image.containerRegistry` for the upstream chart's image resolution.
   - Maps proxy settings from GS format to upstream format (`proxy.http_proxy` / `proxy.no_proxy`).
   - Routes upstream values under the `upstream:` key.
   - Routes extras (`verticalPodAutoscaler`, `networkPolicy`, `global`) at the top level.
   - Excludes bundle-only keys (`ociRepositoryUrl`, `clusterID`, etc.).
3. The resulting values are stored in a ConfigMap on the management cluster.
4. Flux `HelmRelease` pulls the workload chart from the `OCIRepository` and applies values from the ConfigMap.
5. On the workload cluster, the `upstream:` values flow into the unmodified upstream subchart, while top-level extras are consumed by GS templates.

### Why this pattern

- **Unmodified upstream** — upgrading is just a version bump + `helm dependency update`.
- **Separation of concerns** — IAM and Flux live on the management cluster, the app runs on the workload cluster.
- **Single App CR** — users install the bundle once on the management cluster; everything else is automated.

## Installation

Install the chart on the management cluster using an App CR:

```yaml
apiVersion: application.giantswarm.io/v1alpha1
kind: App
metadata:
  name: coyote-aws-ebs-csi-driver-bundle
  namespace: org-acme
spec:
  catalog: default
  config:
    configMap:
      name: coyote-cluster-values
      namespace: org-acme
  kubeConfig:
    inCluster: true
  name: aws-ebs-csi-driver-bundle
  namespace: org-acme
  version: 5.0.0
```

## Upgrade from v4 to v5

v5 migrates from a forked upstream chart to using the unmodified upstream chart as a Helm dependency. Key changes:

- The workload chart is now `aws-ebs-csi-driver` (was `aws-ebs-csi-driver-app`).
- All upstream values are now under the `upstream:` key in the bundle values.
- `nameOverride: aws-ebs-csi-driver` is set automatically to preserve selector compatibility.
- VPA, NetworkPolicy, and PSS exceptions are now managed as GS extras templates.
- Image references use the upstream `containerRegistry` pattern instead of the GS split `registry`+`repository` format.

No manual action is required for standard installations. Custom value overrides should be reviewed to ensure they are placed under the correct key (`upstream:` for upstream values, top-level for extras).

## Testing

CI runs `ct lint` for both charts. To test locally:

```bash
# Lint workload chart
helm dependency update helm/aws-ebs-csi-driver/
helm lint helm/aws-ebs-csi-driver/

# Lint bundle chart (requires cluster context for crossplane lookups)
helm lint helm/aws-ebs-csi-driver-bundle/

# Template workload chart
helm template aws-ebs-csi-driver helm/aws-ebs-csi-driver/
```

## Credit

* https://github.com/kubernetes-sigs/aws-ebs-csi-driver
