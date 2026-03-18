{{/* vim: set filetype=mustache: */}}
{{/*
Selector labels — intentionally empty.
The GS fork removed selectorLabels from Deployment/DaemonSet spec.selector.matchLabels.
The upstream chart hardcodes `app: ebs-csi-controller` / `app: ebs-csi-node` in selectors.
Overriding this to empty preserves selector compatibility during upgrades.
*/}}
{{- define "aws-ebs-csi-driver.selectorLabels" -}}
{{- "" -}}
{{- end -}}

{{/*
Common labels — override to include GS labels and the selector labels that
were removed from selectorLabels above.
Note: this template is called from both the subchart context and the parent
chart context. Use safe accessors that work in both.
*/}}
{{- define "aws-ebs-csi-driver.labels" -}}
app.kubernetes.io/name: {{ include "aws-ebs-csi-driver.name" . }}
{{- if ne .Release.Name "kustomize" }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ include "aws-ebs-csi-driver.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/component: csi-driver
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
giantswarm.io/service-type: managed
application.giantswarm.io/team: {{ index .Chart.Annotations "io.giantswarm.application.team" | quote }}
{{- if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{- end }}
{{- end -}}
