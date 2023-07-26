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
Selector labels
*/}}
{{- define "drupal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "drupal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "drupal.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "drupal.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
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
Set drupal volumes
*/}}
{{- define "drupalVolumes" -}}
- name: crayfish-key
  secret:
    secretName: crayfish-key
    items:
    - key: private
      path: default.pub
- name: public
  persistentVolumeClaim:
    claimName: drupal-public-claim
- name: private
  persistentVolumeClaim:
    claimName: drupal-private-claim
- name: islandora-data
  persistentVolumeClaim:
    claimName: drupal-islandora-data-claim
- name: ingest-data
  persistentVolumeClaim:
    claimName: drupal-ingest-data-claim
- name: root
  persistentVolumeClaim:
    claimName: drupal-root-claim
{{- if .Values.xdebug.enabled -}}
- name: xdebug-ini
  configMap: 
    name: xdebug-ini
{{- end -}}
{{- end -}}

{{/*
Set drupal volume mounts
*/ }}
{{- define "drupalVolumeMounts" -}}
- name: crayfish-key
  mountPath: /run/secrets/crayfish
- name: public
  mountPath: /opt/www/drupal/web/sites/default/files
- name: private
  mountPath: /opt/drupal_private_filesystem/d8/default
- name: islandora-data
  mountPath: /opt/islandora_data
- name: ingest-data
  mountPath: /opt/ingest_data
- name: drupal-php-ini
  mountPath: /etc/php/{{ .Values.drupal.phpVersion }}/apache2/conf.d/99-config.ini
  subPath: 99-config.ini
- name: drupal-php-ini
  mountPath: /etc/php/{{ .Values.drupal.phpVersion }}/cli/conf.d/99-config.ini
  subPath: 99-config.ini
- name: root
  mountPath: /opt/www/drupal
{{- end -}}
