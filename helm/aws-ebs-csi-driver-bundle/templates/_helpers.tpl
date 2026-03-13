{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "aws-ebs-csi-driver-bundle.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aws-ebs-csi-driver-bundle.fullname" -}}
{{- $name := .Chart.Name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aws-ebs-csi-driver-bundle.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resolve clusterID: use .Values.clusterID if set, otherwise derive from
the release name by stripping known chart name suffixes.
*/}}
{{- define "aws-ebs-csi-driver-bundle.clusterID" -}}
{{- if .Values.clusterID -}}
  {{- .Values.clusterID -}}
{{- else -}}
  {{- $name := .Release.Name -}}
  {{- range $suffix := list (printf "-%s" $.Chart.Name) "-aws-ebs-csi-driver-bundle" -}}
    {{- $name = trimSuffix $suffix $name -}}
  {{- end -}}
  {{- if eq $name .Release.Name -}}
    {{- fail "clusterID not set and cannot derive cluster name from release name" -}}
  {{- end -}}
  {{- $name -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "aws-ebs-csi-driver-bundle.labels" -}}
app.kubernetes.io/name: {{ include "aws-ebs-csi-driver-bundle.name" . }}
helm.sh/chart: {{ include "aws-ebs-csi-driver-bundle.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
giantswarm.io/service-type: "managed"
application.giantswarm.io/team: {{ index .Chart.Annotations "application.giantswarm.io/team" | quote }}
giantswarm.io/cluster: {{ include "aws-ebs-csi-driver-bundle.clusterID" . | quote }}
{{- end -}}

{{/*
Fetch crossplane config ConfigMap data
*/}}
{{- define "aws-ebs-csi-driver-bundle.crossplaneConfigData" -}}
{{- $clusterName := (include "aws-ebs-csi-driver-bundle.clusterID" .) -}}
{{- $configmap := (lookup "v1" "ConfigMap" .Release.Namespace (printf "%s-crossplane-config" $clusterName)) -}}
{{- $cmvalues := dict -}}
{{- if and $configmap $configmap.data $configmap.data.values -}}
  {{- $cmvalues = fromYaml $configmap.data.values -}}
{{- else -}}
  {{- fail (printf "Crossplane config ConfigMap %s-crossplane-config not found in namespace %s or has no data" $clusterName .Release.Namespace) -}}
{{- end -}}
{{- $cmvalues | toYaml -}}
{{- end -}}

{{/*
Get trust policy statements for all provided OIDC domains
*/}}
{{- define "aws-ebs-csi-driver-bundle.trustPolicyStatements" -}}
{{- $cmvalues := (include "aws-ebs-csi-driver-bundle.crossplaneConfigData" .) | fromYaml -}}
{{- range $index, $oidcDomain := $cmvalues.oidcDomains -}}
{{- if not (eq $index 0) }}, {{ end }}{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:{{ $cmvalues.awsPartition }}:iam::{{ $cmvalues.accountID }}:oidc-provider/{{ $oidcDomain }}"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "{{ $oidcDomain }}:sub": "system:serviceaccount:kube-system:{{ $.Values.controller.serviceAccount.name }}"
    }
  }
}
{{- end -}}
{{- end -}}

{{/*
Set Giant Swarm specific values — computes IRSA role ARN.
*/}}
{{- define "giantswarm.setValues" -}}
{{- $cmvalues := (include "aws-ebs-csi-driver-bundle.crossplaneConfigData" .) | fromYaml -}}
{{- $clusterID := (include "aws-ebs-csi-driver-bundle.clusterID" .) -}}
{{- $_ := set .Values.controller.serviceAccount.annotations "eks.amazonaws.com/role-arn" (printf "arn:%s:iam::%s:role/%s-ebs-csi-driver" $cmvalues.awsPartition $cmvalues.accountID $clusterID) -}}
{{- if and (not .Values.clusterName) -}}
{{- $_ := set .Values "clusterName" $clusterID -}}
{{- end -}}
{{/* Default extraVolumeTags: tag EBS volumes with the cluster name so we know
     which cluster they belong to. User-supplied tags (root or controller level)
     are merged on top. */}}
{{- $evtDefaults := dict "sigs.k8s.io/cluster-name" $clusterID -}}
{{- $evtUser := dict -}}
{{- if .Values.extraVolumeTags -}}
  {{- $evtUser = .Values.extraVolumeTags -}}
{{- end -}}
{{- if .Values.controller -}}
  {{- if .Values.controller.extraVolumeTags -}}
    {{- $evtUser = merge $evtUser .Values.controller.extraVolumeTags -}}
  {{- end -}}
{{- end -}}
{{- $_ := set .Values "controller" (merge (dict "extraVolumeTags" (merge $evtUser $evtDefaults)) (default dict .Values.controller)) -}}
{{- end -}}

{{/*
Reusable: combine GS split registry+repository into upstream single repository.
Preserves all other keys (tag, pullPolicy, etc.) from the input dict.
*/}}
{{- define "giantswarm.combineImage" -}}
{{- $result := deepCopy . -}}
{{- $_ := set $result "repository" (printf "%s/%s" .registry .repository) -}}
{{- $_ := unset $result "registry" -}}
{{- $result | toYaml -}}
{{- end -}}

{{/*
Transform flat bundle values into the nested workload chart structure.
The workload chart expects:
  - upstream: {} — values for the upstream subchart dependency
  - networkPolicy: {} — extras
  - verticalPodAutoscaler: {} — extras
  - global: {} — extras

Keys listed in $bundleOnlyKeys and $extrasKeys are excluded from upstream.
Any other key in .Values passes through to upstream automatically.
*/}}
{{- define "giantswarm.workloadValues" -}}
{{- include "giantswarm.setValues" . -}}
{{- $upstreamValues := dict -}}

{{/* Keys that belong to the bundle chart itself (never forwarded) */}}
{{- $bundleOnlyKeys := list "ociRepositoryUrl" "clusterID" "clusterName" -}}
{{/* Keys forwarded as workload extras (not under upstream:) */}}
{{- $extrasKeys := list "networkPolicy" "verticalPodAutoscaler" "global" -}}
{{/* Keys with special handling */}}
{{- $specialKeys := list "image" "sidecars" "controller" "node" "storageClasses" "extraVolumeTags" -}}
{{- $reservedKeys := concat $bundleOnlyKeys $extrasKeys $specialKeys -}}

{{/* Image: combine GS split format; set containerRegistry to empty since
     the upstream chart prepends it to repository (fullImagePath helper) */}}
{{- $combinedImage := include "giantswarm.combineImage" .Values.image | fromYaml -}}
{{- $_ := set $combinedImage "containerRegistry" "" -}}
{{- $_ := set $upstreamValues "image" $combinedImage -}}

{{/* Sidecars: combine GS split format for each */}}
{{- $sidecars := deepCopy .Values.sidecars -}}
{{- range $name, $sidecar := .Values.sidecars -}}
  {{- if and $sidecar.image $sidecar.image.registry $sidecar.image.repository -}}
    {{- $_ := set (index $sidecars $name) "image" (include "giantswarm.combineImage" $sidecar.image | fromYaml) -}}
  {{- end -}}
{{- end -}}
{{- $_ := set $upstreamValues "sidecars" $sidecars -}}

{{/* Controller + Node: direct pass-through */}}
{{- $_ := set $upstreamValues "controller" (deepCopy .Values.controller) -}}
{{- $_ := set $upstreamValues "node" (deepCopy .Values.node) -}}

{{/* storageClasses: forwarded to upstream */}}
{{- if .Values.storageClasses -}}
{{- $_ := set $upstreamValues "storageClasses" .Values.storageClasses -}}
{{- end -}}

{{/* Preserve the original chart name so selectors stay compatible with pre-dependency upgrades */}}
{{- $_ := set $upstreamValues "nameOverride" "aws-ebs-csi-driver" -}}

{{/* Pass through any non-reserved value to upstream (e.g. useFIPS, imagePullSecrets) */}}
{{- range $key, $val := .Values -}}
  {{- if not (has $key $reservedKeys) -}}
  {{- $_ := set $upstreamValues $key $val -}}
  {{- end -}}
{{- end -}}

{{/* Assemble workload values: upstream + extras */}}
{{- $workloadValues := dict "upstream" $upstreamValues -}}
{{- $_ := set $workloadValues "networkPolicy" .Values.networkPolicy -}}
{{- $_ := set $workloadValues "verticalPodAutoscaler" .Values.verticalPodAutoscaler -}}
{{- $_ := set $workloadValues "global" .Values.global -}}

{{- $workloadValues | toYaml -}}
{{- end -}}
