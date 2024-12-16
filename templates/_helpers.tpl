{{/*
Expand the name of the chart.
*/}}
{{- define "linkwarden.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "linkwarden.fullname" -}}
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
{{- define "linkwarden.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "linkwarden.selectorLabels" -}}
app.kubernetes.io/name: {{ include "linkwarden.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "linkwarden.labels" -}}
helm.sh/chart: {{ include "linkwarden.chart" . }}
app.kubernetes.io/part-of: {{ .Release.Name }}
{{ include "linkwarden.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "linkwarden.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "linkwarden.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define whether any SSO provider is enabled
*/}}
{{- define "linkwarden.ssoEnabled" -}}
  {{- $ssoEnabled := false -}}
  {{- range $provider, $config := .Values.linkwarden.sso.providers -}}
    {{- if $config.enabled -}}
      {{- $ssoEnabled = true -}}
      {{- break -}}
    {{- end -}}
  {{- end -}}
  {{- $ssoEnabled -}}
{{- end -}}

{{/*
Validate auth configuration
*/}}
{{- define "linkwarden.validateAuth" -}}
  {{- if not .Values.linkwarden.existingSecret -}}
    {{- if not .Values.linkwarden.nextAuthUrl -}}
      {{- fail "NextAuth URL must be set" -}}
    {{- end -}}
    {{- if not .Values.linkwarden.nextAuthSecret -}}
      {{- fail "NextAuth secret must be set" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Validate storage configuration
*/}}
{{- define "linkwarden.validateStorage" -}}
  {{- if eq .Values.linkwarden.storage.type "filesystem" -}}
    {{- if not .Values.linkwarden.storage.storageFolder -}}
      {{- fail "Storage folder must be set when using filesystem storage type" -}}
  {{- end -}}
  {{- else if and (eq .Values.linkwarden.storage.type "s3") (not .Values.linkwarden.existingSecret) -}}
    {{- if not .Values.linkwarden.storage.s3.endpoint -}}
      {{- fail "S3 endpoint must be set when using s3 storage type" -}}
    {{- end -}}
    {{- if not .Values.linkwarden.storage.s3.region -}}
      {{- fail "S3 region must be set when using s3 storage type" -}}
    {{- end -}}
    {{- if not .Values.linkwarden.storage.s3.accessKey -}}
      {{- fail "S3 access key must be set when using s3 storage type" -}}
    {{- end -}}
    {{- if not .Values.linkwarden.storage.s3.secretKey -}}
      {{- fail "S3 secret key must be set when using s3 storage type" -}}
    {{- end -}}
    {{- if not .Values.linkwarden.storage.s3.bucketName -}}
      {{- fail "S3 bucket name must be set when using s3 storage type" -}}
    {{- end -}}
  {{- else -}}
    {{- fail "Invalid storage type. Must be either 'filesystem' or 's3'" -}}
  {{- end -}}
{{- end -}}

{{/*
Validate Email Configuration
*/}}
{{- define "linkwarden.validateEmail" -}}
  {{- if and (.Values.linkwarden.emailProvider) (not .Values.linkwarden.existingSecret) -}}
    {{- if not .Values.linkwarden.emailFrom -}}
      {{- fail "Email from must be set when using email provider" -}}
    {{- end -}}
    {{- if not .Values.linkwarden.emailServer -}}
      {{- fail "Email server must be set when using email provider" -}}
    {{- end -}}
  {{- end }}
{{- end -}}

{{/*
All Validations
*/}}
{{- define "linkwarden.validateAll" -}}
  {{- include "linkwarden.validateAuth" . -}}
  {{- include "linkwarden.validateStorage" . -}}
  {{- include "linkwarden.validateEmail" . -}}
{{- end -}}