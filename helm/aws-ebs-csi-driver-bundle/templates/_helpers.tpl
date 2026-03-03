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
giantswarm.io/cluster: {{ .Values.clusterID | quote }}
{{- end -}}

{{/*
Fetch crossplane config ConfigMap data
*/}}
{{- define "aws-ebs-csi-driver-bundle.crossplaneConfigData" -}}
{{- $configmap := (lookup "v1" "ConfigMap" .Release.Namespace (printf "%s-crossplane-config" .Values.clusterID)) -}}
{{- $cmvalues := dict -}}
{{- if and $configmap $configmap.data $configmap.data.values -}}
  {{- $cmvalues = fromYaml $configmap.data.values -}}
{{- else -}}
  {{- fail (printf "Crossplane config ConfigMap %s-crossplane-config not found in namespace %s or has no data" .Values.clusterID .Release.Namespace) -}}
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
Generate workload chart values from bundle values.
Transforms flat bundle values into nested structure with upstream: key.
Incorporates IAM role ARN injection (replaces giantswarm.setValues).
Handles:
  - proxy/cluster keys → global.proxy/global.clusterProxy (not in upstream schema)
  - sidecar images → prepend registry to repository (upstream has no containerRegistry for sidecars)
  - main image → set containerRegistry with trailing slash (upstream supports this)
*/}}
{{- define "giantswarm.workloadValues" -}}
{{- $cmvalues := (include "aws-ebs-csi-driver-bundle.crossplaneConfigData" .) | fromYaml -}}
{{- $iamRoleArn := printf "arn:%s:iam::%s:role/%s-ebs-csi-driver" $cmvalues.awsPartition $cmvalues.accountID .Values.clusterID -}}

{{- /* Keys that should not be forwarded under upstream */ -}}
{{- $excludeKeys := list "clusterID" "bundleNameOverride" "fullBundleNameOverride" "ociRepositoryUrl" "global" "proxy" "cluster" -}}

{{- /* Build upstream values from all non-excluded keys */ -}}
{{- $upstream := dict -}}
{{- range $key, $val := .Values -}}
  {{- if not (has $key $excludeKeys) -}}
    {{- $_ := set $upstream $key $val -}}
  {{- end -}}
{{- end -}}

{{- /* Always set nameOverride */ -}}
{{- $_ := set $upstream "nameOverride" "aws-ebs-csi-driver" -}}

{{- /* Add containerRegistry (with trailing slash) to main image */ -}}
{{- /* Upstream uses image.containerRegistry for both main image and sidecars */ -}}
{{- $registry := .Values.global.image.registry -}}
{{- if $registry -}}
  {{- $registryWithSlash := printf "%s/" $registry -}}
  {{- if index $upstream "image" -}}
    {{- $_ := set (index $upstream "image") "containerRegistry" $registryWithSlash -}}
  {{- end -}}
{{- end -}}

{{- /* Set IAM role ARN in controller.serviceAccount.annotations */ -}}
{{- if index $upstream "controller" -}}
  {{- $controller := index $upstream "controller" -}}
  {{- if index $controller "serviceAccount" -}}
    {{- $sa := index $controller "serviceAccount" -}}
    {{- if not (index $sa "annotations") -}}
      {{- $_ := set $sa "annotations" (dict) -}}
    {{- end -}}
    {{- $_ := set (index $sa "annotations") "eks.amazonaws.com/role-arn" $iamRoleArn -}}
  {{- end -}}
{{- end -}}

{{- /* Build global values: merge image registry + proxy settings */ -}}
{{- $globalVal := dict -}}
{{- $_ := set $globalVal "image" .Values.global.image -}}
{{- /* Map bundle proxy → global.proxy, cluster.proxy → global.clusterProxy */ -}}
{{- if .Values.proxy -}}
  {{- $_ := set $globalVal "proxy" .Values.proxy -}}
{{- end -}}
{{- if and .Values.cluster .Values.cluster.proxy -}}
  {{- $_ := set $globalVal "clusterProxy" .Values.cluster.proxy -}}
{{- end -}}

{{- /* Build output */ -}}
{{- $output := dict -}}
{{- $_ := set $output "clusterID" .Values.clusterID -}}
{{- $_ := set $output "upstream" $upstream -}}
{{- $_ := set $output "global" $globalVal -}}

{{- $output | toYaml -}}
{{- end -}}
