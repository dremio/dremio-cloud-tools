{{/*
Shared - Image Pull Secrets
*/}}
{{- define "dremio.imagePullSecrets" -}}
{{- if .Values.imagePullSecrets }}
imagePullSecrets:
{{- range $secretName := .Values.imagePullSecrets }}
- name: {{ $secretName }}
{{- end}}
{{- end -}}
{{- end -}}