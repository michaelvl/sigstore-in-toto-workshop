{{/*
Expand the name of the chart.
*/}}
{{- define "sigstore-in-toto-workshop-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sigstore-in-toto-workshop-helm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "sigstore-in-toto-workshop-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sigstore-in-toto-workshop-helm.labels" -}}
helm.sh/chart: {{ include "sigstore-in-toto-workshop-helm.chart" . }}
{{ include "sigstore-in-toto-workshop-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sigstore-in-toto-workshop-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sigstore-in-toto-workshop-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sigstore-in-toto-workshop-helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sigstore-in-toto-workshop-helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the container image URL. This implements the 'both tag and digest can be specified' approach
*/}}
{{- define "image" -}}
{{- $defaultTag := index . 1 -}}
{{- with index . 0 -}}
{{- if .registry -}}{{ printf "%s/%s" .registry .repository }}{{- else -}}{{- .repository -}}{{- end -}}
{{- if .tag -}}{{ printf ":%s" (default $defaultTag .tag) }}{{- end -}}
{{- if .digest -}}{{ printf "@%s" .digest }}{{- end -}}
{{- end }}
{{- end }}
