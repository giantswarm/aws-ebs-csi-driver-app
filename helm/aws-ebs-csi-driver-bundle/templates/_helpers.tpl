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
Set Giant Swarm specific values
*/}}
{{- define "giantswarm.setValues" -}}
{{- $cmvalues := (include "aws-ebs-csi-driver-bundle.crossplaneConfigData" .) | fromYaml -}}
{{- $roleArn := printf "arn:%s:iam::%s:role/%s-ebs-csi-driver" $cmvalues.awsPartition $cmvalues.accountID .Values.clusterID -}}
{{- $audience := "sts.amazonaws.com" -}}
{{- if eq $cmvalues.awsPartition "aws-cn" -}}
{{- $audience = "sts.amazonaws.com.cn" -}}
{{- end -}}
{{/* ServiceAccount annotation */}}
{{- $_ := set .Values.controller.serviceAccount.annotations "eks.amazonaws.com/role-arn" $roleArn -}}
{{/* AWS region — the inner chart renders this as the AWS_REGION env var */}}
{{- $_ := set .Values.controller "region" $cmvalues.region -}}
{{/* IRSA env vars */}}
{{- $irsaEnv := list
  (dict "name" "AWS_ROLE_ARN" "value" $roleArn)
  (dict "name" "AWS_WEB_IDENTITY_TOKEN_FILE" "value" "/var/run/secrets/eks.amazonaws.com/serviceaccount/token")
-}}
{{- $_ := set .Values.controller "env" (concat $irsaEnv .Values.controller.env) -}}
{{/* Projected ServiceAccountToken volume */}}
{{- $irsaVolume := list
  (dict "name" "aws-iam-token" "projected" (dict "sources" (list
    (dict "serviceAccountToken" (dict "audience" $audience "expirationSeconds" 86400 "path" "token"))
  )))
-}}
{{- $_ := set .Values.controller "volumes" (concat $irsaVolume .Values.controller.volumes) -}}
{{/* Volume mount for the projected token */}}
{{- $irsaVolumeMount := list
  (dict "name" "aws-iam-token" "mountPath" "/var/run/secrets/eks.amazonaws.com/serviceaccount/" "readOnly" true)
-}}
{{- $_ := set .Values.controller "volumeMounts" (concat $irsaVolumeMount .Values.controller.volumeMounts) -}}
{{- end -}}
