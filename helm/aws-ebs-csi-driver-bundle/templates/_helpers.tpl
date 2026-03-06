{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "aws-ebs-csi-driver-bundle.name" -}}
{{- default .Chart.Name .Values.bundleNameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aws-ebs-csi-driver-bundle.fullname" -}}
{{- if .Values.fullBundleNameOverride -}}
{{- .Values.fullBundleNameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.bundleNameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aws-ebs-csi-driver-bundle.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.AppVersion | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
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
      "{{ $oidcDomain }}:sub": "system:serviceaccount:kube-system:{{ $.Values.upstream.controller.serviceAccount.name }}"
    }
  }
}
{{- end -}}
{{- end -}}

{{/*
Set Giant Swarm specific values — computes IRSA role ARN and injects it.
*/}}
{{- define "giantswarm.setValues" -}}
{{- $cmvalues := (include "aws-ebs-csi-driver-bundle.crossplaneConfigData" .) | fromYaml -}}
{{- $clusterID := (include "aws-ebs-csi-driver-bundle.clusterID" .) -}}
{{- $_ := set .Values.upstream.controller.serviceAccount.annotations "eks.amazonaws.com/role-arn" (printf "arn:%s:iam::%s:role/%s-ebs-csi-driver" $cmvalues.awsPartition $cmvalues.accountID $clusterID) -}}
{{- end -}}

{{/*
Transform flat bundle values into the nested workload chart structure.
Builds:
  clusterID: ...
  upstream:
    nameOverride: aws-ebs-csi-driver
    image: (with containerRegistry from global.image.registry)
    controller: (with IRSA annotation)
    ...
  verticalPodAutoscaler: ...
  networkPolicy: ...
  global: ...
*/}}
{{- define "giantswarm.workloadValues" -}}
{{- include "giantswarm.setValues" . -}}
{{- $clusterID := (include "aws-ebs-csi-driver-bundle.clusterID" .) -}}

{{/* Keys that belong to the bundle chart itself (never forwarded) */}}
{{- $bundleOnlyKeys := list "ociRepositoryUrl" "clusterID" "bundleNameOverride" "fullBundleNameOverride" "proxy" "cluster" "global" -}}
{{/* Keys forwarded as workload extras (not under upstream:) */}}
{{- $extrasKeys := list "networkPolicy" "verticalPodAutoscaler" -}}
{{/* Keys with special handling */}}
{{- $specialKeys := list "upstream" -}}
{{- $reservedKeys := concat $bundleOnlyKeys $extrasKeys $specialKeys -}}

{{/* Start from the explicit upstream values */}}
{{- $upstream := deepCopy .Values.upstream -}}

{{/* Preserve the original chart name for selector compatibility */}}
{{- $_ := set $upstream "nameOverride" "aws-ebs-csi-driver" -}}

{{/* Add containerRegistry (with trailing slash) to main image */}}
{{/* Upstream uses image.containerRegistry as prefix for all images (main + sidecars) */}}
{{- $registry := .Values.global.image.registry -}}
{{- if $registry -}}
  {{- $registryWithSlash := printf "%s/" $registry -}}
  {{- if index $upstream "image" -}}
    {{- $_ := set (index $upstream "image") "containerRegistry" $registryWithSlash -}}
  {{- end -}}
{{- end -}}

{{/* Map proxy settings to upstream format (proxy.http_proxy / proxy.no_proxy) */}}
{{/* Merge cluster.proxy (base) with proxy (override); local proxy values win */}}
{{- $httpProxy := "" -}}
{{- $noProxy := "" -}}
{{- if and .Values.cluster .Values.cluster.proxy -}}
  {{- $httpProxy = default "" .Values.cluster.proxy.http -}}
  {{- $noProxy = default "" .Values.cluster.proxy.noProxy -}}
{{- end -}}
{{- if .Values.proxy -}}
  {{- if .Values.proxy.http -}}
    {{- $httpProxy = .Values.proxy.http -}}
  {{- end -}}
  {{- if .Values.proxy.noProxy -}}
    {{- $noProxy = .Values.proxy.noProxy -}}
  {{- end -}}
{{- end -}}
{{- if $httpProxy -}}
  {{- $_ := set $upstream "proxy" (dict "http_proxy" $httpProxy "no_proxy" $noProxy) -}}
{{- end -}}

{{/* Pass through any non-reserved value to upstream (future-proofing) */}}
{{- range $key, $val := .Values -}}
  {{- if not (has $key $reservedKeys) -}}
    {{- $_ := set $upstream $key $val -}}
  {{- end -}}
{{- end -}}

{{/* Assemble workload values: clusterID + upstream + extras */}}
{{- $workloadValues := dict "upstream" $upstream -}}
{{- $_ := set $workloadValues "clusterID" $clusterID -}}
{{- if .Values.verticalPodAutoscaler -}}
{{- $_ := set $workloadValues "verticalPodAutoscaler" .Values.verticalPodAutoscaler -}}
{{- end -}}
{{- if .Values.networkPolicy -}}
{{- $_ := set $workloadValues "networkPolicy" .Values.networkPolicy -}}
{{- end -}}
{{- $pssEnforced := true -}}
{{- if hasKey .Values "global" -}}
  {{- $globalMap := .Values.global | deepCopy -}}
  {{- if hasKey $globalMap "podSecurityStandards" -}}
    {{- if hasKey $globalMap.podSecurityStandards "enforced" -}}
      {{- $pssEnforced = $globalMap.podSecurityStandards.enforced -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $_ := set $workloadValues "global" (dict "podSecurityStandards" (dict "enforced" $pssEnforced)) -}}

{{- $workloadValues | toYaml -}}
{{- end -}}
