{{/*
Shared - Image Pull Secrets
*/}}
{{- define "dremio.imagePullSecrets" -}}
{{- if $.Values.imagePullSecrets }}
imagePullSecrets:
{{- range $secretName := $.Values.imagePullSecrets }}
- name: {{ $secretName }}
{{- end}}
{{- end -}}
{{- end -}}

{{/*
Shared - Secrets
*/}}
{{- define "dremio.secrets" -}}
{{- $secrets:= coalesce $.Values.secrets -}}
{{- if $secrets -}}
{{- toYaml $secrets -}}
{{- end -}}
{{- end -}}

{{/*
Shared - Secrets Environment Variables
*/}}
{{- define "dremio.secretsEnvironmentVariables" -}}
{{- range $secretName, $secretValue := coalesce $.Values.secrets }}
- name: {{ $secretName }}
  valueFrom:
    secretKeyRef:
      name: dremio-secrets
      key: {{ $secretName }}
{{- end -}}
{{- end -}}

{{/*
Shared - Additional Configuration Environment Variables
*/}}
{{- define "dremio.additionalConfigsEnvironmentVariables" -}}
{{- range $configName, $configValue := coalesce $.Values.additionalConfigMap }}
- name: {{ $configName }}
  valueFrom:
    configMapKeyRef:
      name: dremio-addtional-configs
      key: {{ $configName }}
{{- end -}}
{{- end -}}

{{/*
Service - Annotations
*/}}
{{- define "dremio.service.annotations" -}}
{{- $serviceAnnotations := coalesce $.Values.service.annotations $.Values.annotations -}}
{{- if $.Values.service.internalLoadBalancer }}
annotations:
  service.beta.kubernetes.io/azure-load-balancer-internal: "true"
  cloud.google.com/load-balancer-type: "Internal"
  service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
  {{- if $serviceAnnotations -}}
  {{- toYaml $serviceAnnotations | nindent 2 -}}
  {{- end -}}
{{- else -}}
{{ if $serviceAnnotations }}
annotations:
  {{- toYaml $serviceAnnotations | nindent 4 -}}
{{- end -}}
{{- end }}
{{- end -}}

{{/*
Service - Labels
*/}}
{{- define "dremio.service.labels" -}}
{{- $serviceLabels := coalesce $.Values.service.labels $.Values.labels -}}
{{- if $serviceLabels -}}
{{- toYaml $serviceLabels }}
{{- end -}}
{{- end -}}

{{/*
Admin - Pod Annotations
*/}}
{{- define "dremio.admin.podAnnotations" -}}
{{- $adminPodAnnotations := coalesce $.Values.coordinator.podAnnotations $.Values.podAnnotations -}}
{{- if $adminPodAnnotations -}}
annotations:
  {{- toYaml $adminPodAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Admin - Pod Labels
*/}}
{{- define "dremio.admin.podLabels" -}}
{{- $adminPodLabels := coalesce $.Values.coordinator.podLabels $.Values.podLabels -}}
{{- if $adminPodLabels -}}
labels:
  {{- toYaml $adminPodLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Admin - Pod Node Selectors
*/}}
{{- define "dremio.admin.nodeSelector" -}}
{{- $adminNodeSelector := coalesce $.Values.coordinator.nodeSelector $.Values.nodeSelector -}}
{{- if $adminNodeSelector -}}
nodeSelector:
  {{- toYaml $adminNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Admin - Pod Tolerations
*/}}
{{- define "dremio.admin.tolerations" -}}
{{- $adminPodTolerations := coalesce $.Values.coordinator.tolerations $.Values.tolerations -}}
{{- if $adminPodTolerations -}}
tolerations:
  {{- toYaml $adminPodTolerations | nindent 2 }}
{{- end -}}
{{- end -}}