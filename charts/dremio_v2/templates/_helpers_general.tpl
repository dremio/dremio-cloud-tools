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
Shared - Pod Security Context
*/}}
{{- define "dremio.podSecurityContext" -}}
securityContext:
  fsGroup: 999
  fsGroupChangePolicy: OnRootMismatch
{{- end -}}

{{/*
Shared - Container Security Context
*/}}
{{- define "dremio.containerSecurityContext" -}}
securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  privileged: false
  readOnlyRootFilesystem: false
  runAsGroup: 999
  runAsNonRoot: true
  runAsUser: 999
  seccompProfile:
    type: RuntimeDefault
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

{{/*
Admin - Service Account
*/}}
{{- define "dremio.admin.serviceAccount" -}}
{{- $adminServiceAccount := $.Values.coordinator.serviceAccount -}}
{{- if $adminServiceAccount -}}
serviceAccount: {{ $adminServiceAccount }}
{{- end -}}
{{- end -}}

{{/*
This helper function is used to coalesce a list of boolean values using "trilean" logic,
i.e., returning the first non-nil value found, even if it is false.
If a non-nil value is found and it is true, the function returns "1"; otherwise the function returns an empty string.
This function is suitable for use in lieu of the coalesce function, which has surprising effects
when used with boolean values. This function should not be used with non-boolean values.
*/}}
{{- define "dremio.booleanCoalesce" -}}
{{- $found := false -}}
{{- range $value := . -}}
{{- if and (not $found) (ne $value nil) -}}
{{- $found = true -}}
{{- if $value -}}1{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
