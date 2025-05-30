{{/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *
  *  Name (defaults to "panop") and a fully qualified name
  *  (defaults to "<release>-panop") of controller and a variant with `.Values.defaultBackend.name`
  *  for the default backend.
  *
  *  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  *  If release name contains the chart name, it will be used as a full name.
  *
  */}}

{{- define "panop.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "panop.fullname" -}}
    {{- if contains .Chart.Name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}

{{/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *
  *  Common and selector labels
  *
  *  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  *
  */}}
{{- define "panop.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "panop.labels" -}}
helm.sh/chart: {{ include "panop.chart" . }}
monitoring: apps
{{ include "panop.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "panop.selectorLabels" -}}
app.kubernetes.io/name: {{ include "panop.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "dockerconfigjson.b64dec" }}
  {{- print "{\"auths\":{" }}
  {{- range $index, $item := .Values.imageCredentials }}
    {{- if $index }}
      {{- print "," }}
    {{- end }}
    {{- printf "\"%s\":{\"auth\":\"%s\"}" (default "https://index.docker.io/v1/" $item.registry) (printf "%s:%s" $item.username $item.accessToken | b64enc) }}
  {{- end }}
  {{- print "}}" }}
{{- end }}

{{/*
  Generate the base64-encoded .dockerconfigjson.
  See https://github.com/helm/helm/issues/3691#issuecomment-386113346
*/}}
{{- define "dockerconfigjson.b64enc" }}
  {{- include "dockerconfigjson.b64dec" . | b64enc }}
{{- end }}
