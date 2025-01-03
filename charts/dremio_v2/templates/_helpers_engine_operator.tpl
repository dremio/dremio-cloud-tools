{{/*
Engines - Coordinator Container Extra Environment Variables
*/}}
{{- define "dremio.coordinator.engine.envs" -}}
{{- if $.Values.engine.enabled -}}
- name: "EXECUTOR_IMAGE"
  value: {{ $.Values.image }}:{{ $.Values.imageTag }}
- name: "KUBERNETES_NAMESPACE"
  valueFrom:
    fieldRef:
      fieldPath: "metadata.namespace"
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Service Account
*/}}
{{- define "dremio.engine.operator.serviceAccount" -}}
{{- $operatorServiceAccount := coalesce $.Values.engine.operator.serviceAccount $.Values.serviceAccount -}}
{{- if $operatorServiceAccount -}}
serviceAccountName: {{ $operatorServiceAccount }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Pod Extra Init Containers
*/}}
{{- define "dremio.engine.operator.extraInitContainers" -}}
{{- $operatorExtraInitContainers := coalesce $.Values.engine.operator.extraInitContainers $.Values.extraInitContainers -}}
{{- if $operatorExtraInitContainers -}}
{{ tpl $operatorExtraInitContainers $ }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Container Extra Environment Variables
*/}}
{{- define "dremio.engine.operator.extraEnvs" -}}
{{- $operatorEnvironmentVariables := default (default (dict) $.Values.extraEnvs) $.Values.engine.operator.extraEnvs -}}
{{- range $index, $environmentVariable:= $operatorEnvironmentVariables -}}
{{- if hasPrefix "DREMIO" $environmentVariable.name -}}
{{ fail "Environment variables cannot begin with DREMIO"}}
{{- end -}}
{{- end -}}
{{- if $operatorEnvironmentVariables -}}
{{ toYaml $operatorEnvironmentVariables }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Deployment Annotations
*/}}
{{- define "dremio.engine.operator.annotations" -}}
{{- $operatorAnnotations := coalesce $.Values.engine.operator.annotations $.Values.annotations -}}
{{- if $operatorAnnotations -}}
annotations:
  {{- toYaml $operatorAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Deployment Labels
*/}}
{{- define "dremio.engine.operator.labels" -}}
{{- $operatorLabels := coalesce $.Values.engine.operator.labels $.Values.labels -}}
{{- if $operatorLabels -}}
labels:
  {{- toYaml $operatorLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Pod Annotations
*/}}
{{- define "dremio.engine.operator.podAnnotations" -}}
{{- $coordiantorPodAnnotations := coalesce $.Values.engine.operator.podAnnotations $.Values.podAnnotations -}}
{{- if $coordiantorPodAnnotations -}}
annotations:
  {{ toYaml $coordiantorPodAnnotations }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Pod Labels
*/}}
{{- define "dremio.engine.operator.podLabels" -}}
{{- $operatorPodLabels := coalesce $.Values.engine.operator.podLabels $.Values.podLabels -}}
{{- if $operatorPodLabels -}}
{{ toYaml $operatorPodLabels }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Pod Node Selectors
*/}}
{{- define "dremio.engine.operator.nodeSelector" -}}
{{- $operatorNodeSelector := coalesce $.Values.engine.operator.nodeSelector $.Values.nodeSelector -}}
{{- if $operatorNodeSelector -}}
nodeSelector:
  {{- toYaml $operatorNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Engine Operator - Pod Tolerations
*/}}
{{- define "dremio.engine.operator.tolerations" -}}
{{- $operatorTolerations := coalesce $.Values.engine.operator.tolerations $.Values.tolerations -}}
{{- if $operatorTolerations -}}
tolerations:
  {{- toYaml $operatorTolerations | nindent 2 }}
{{- end -}}
{{- end -}}