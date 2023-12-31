{{/*
Get a list of trusted hostnames
*/}}
{{- define "drupal.trustedHosts" -}}
{{- $serviceName := "svc-drupal" -}}
{{- $namespaced := print $serviceName "." .Release.Namespace  -}}
{{- $fullName := print $namespaced ".svc.cluster.local" -}}
{{- $baseNames := list "localhost" $serviceName $namespaced $fullName -}}
{{ .Values.ingress.host | append $baseNames | toJson | quote }}
{{- end }}

{{/*
Choose http scheme
*/}}
{{- define "http.scheme" -}}
{{- if .Values.ingress.tls.enabled -}}
websecure
{{- else -}}
web
{{- end -}}
{{- end -}}

{{/*
Choose http scheme
*/}}
{{- define "http.protocol" -}}
{{- if .Values.ingress.tls.enabled -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "drupal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "drupal.fullname" -}}
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
{{- define "drupal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "drupal.labels" -}}
helm.sh/chart: {{ include "drupal.chart" . }}
{{ include "drupal.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Service account
*/}}
{{- define "drupal.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "drupal.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "drupal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "drupal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


