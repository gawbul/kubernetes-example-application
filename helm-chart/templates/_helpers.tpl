{{/*
Expand the name of the chart.
*/}}
{{- define "example-application.name" -}}
{{- default .Chart.Name .Values.application.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If the release name contains the chart name it will be used as a full name.
*/}}
{{- define "example-application.fullname" -}}
{{- if .Values.application.fullnameOverride }}
{{- .Values.application.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.application.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "example-application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "example-application.labels" -}}
helm.sh/chart: {{ include "example-application.chart" . }}
{{ include "example-application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "example-application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "example-application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "example-application.serviceAccountName" -}}
{{- if .Values.application.serviceAccount.create }}
{{- default (include "example-application.fullname" .) .Values.application.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.application.serviceAccount.name }}
{{- end }}
{{- end }}
