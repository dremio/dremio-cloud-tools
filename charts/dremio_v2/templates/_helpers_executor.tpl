
{{/*
Executor - Dremio Heap Memory Allocation
*/}}
{{- define "dremio.executor.heapMemory" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineMemory := int (default $context.Values.executor.memory $engineConfiguration.memory) -}}
{{- if gt 4096 $engineMemory -}}
{{ fail "Dremio's minimum memory requirement is 4 GB." }}
{{- end -}}
{{- if le 32786 $engineMemory -}}
8192
{{- else if le 6144 $engineMemory -}}
4096
{{- else -}}
2048
{{- end -}}
{{- end -}}

{{/*
Executor - Dremio Direct Memory Allocation
*/}}
{{- define "dremio.executor.directMemory" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineMemory := int (default $context.Values.executor.memory $engineConfiguration.memory) -}}
{{- if gt 4096 $engineMemory -}}
{{ fail "Dremio's minimum memory requirement is 4 GB." }}
{{- end -}}
{{- if le 32786 $engineMemory -}}
{{- sub $engineMemory 8192 -}}
{{- else if le 6144 $engineMemory -}}
{{- sub $engineMemory 6144 -}}
{{- else -}}
{{- sub $engineMemory 2048 -}}
{{- end -}}
{{- end -}}

{{/*
Executor - CPU Resource Request
*/}}
{{- define "dremio.executor.cpu" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineCpu := default ($context.Values.executor.cpu) $engineConfiguration.cpu -}}
{{- $engineCpu -}}
{{- end -}}

{{/*
Executor - Memory Resource Request
*/}}
{{- define "dremio.executor.memory" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineMemory := default ($context.Values.executor.memory) $engineConfiguration.memory -}}
{{- $engineMemory -}}M
{{- end -}}

{{/*
Executor - Replication Count
*/}}
{{- define "dremio.executor.count" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineCount := default ($context.Values.executor.count) $engineConfiguration.count -}}
{{- $engineCount -}}
{{- end -}}

{{/*
Executor - ConfigMap
*/}}
{{- define "dremio.executor.config" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- if hasKey (default (dict) $context.Values.executor.engineOverride) $engineName -}}
{{- printf "dremio-config-%v" $engineName -}}
{{- else -}}
dremio-config
{{- end -}}
{{- end -}}

{{/*
Executor - Dremio Start Parameters
*/}}
{{- define "dremio.executor.extraStartParams" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineExtraStartParams := default (default (default "" $context.Values.extraStartParams) $context.Values.executor.extraStartParams) $engineConfiguration.extraStartParams -}}
{{- if $engineExtraStartParams}}
{{- printf "%v " $engineExtraStartParams -}}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Extra Init Containers
*/}}
{{- define "dremio.executor.extraInitContainers" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineExtraInitContainers := default (default (default "" $context.Values.extraInitContainers) $context.Values.executor.extraInitContainers) $engineConfiguration.extraInitContainers -}}
{{- if $engineExtraInitContainers -}}
{{ tpl $engineExtraInitContainers $ }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Extra Volume Mounts
*/}}
{{- define "dremio.executor.extraVolumeMounts" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineExtraVolumeMounts := default (default (default "" $context.Values.extraVolumeMounts) $context.Values.executor.extraVolumeMounts) $engineConfiguration.extraVolumeMounts -}}
{{- if $engineExtraVolumeMounts -}}
{{ toYaml $engineExtraVolumeMounts }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Extra Volume Mounts
*/}}
{{- define "dremio.executor.extraVolumes" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineExtraVolumes := default (default (default "" $context.Values.extraVolumes) $context.Values.executor.extraVolumes) $engineConfiguration.extraVolumes -}}
{{- if $engineExtraVolumes -}}
{{ toYaml $engineExtraVolumes }}
{{- end -}}
{{- end -}}

{{/*
Executor - Persistent Volume Storage Class
*/}}
{{- define "dremio.executor.storageClass" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineStorageClass := default (default (default (dict) $context.Values.storageClass) $context.Values.executor.storageClass) $engineConfiguration.storageClass -}}
{{- if $engineStorageClass -}}
storageClass: {{ $engineStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Executor - Persistent Volume Size
*/}}
{{- define "dremio.executor.volumeSize" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineVolumeSize := default ($context.Values.executor.volumeSize) $engineConfiguration.volumeSize -}}
{{- $engineVolumeSize -}}
{{- end -}}

{{/*
Executor - Persistent Volume Name
*/}}
{{- define "dremio.executor.volumeClaimName" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $volumeClaimName := default (printf "dremio-%v-executor-volume" $engineName) $engineConfiguration.volumeClaimName -}}
{{- $volumeClaimName -}}
{{- end -}}

{{/*
Executor - StatefulSet Annotations
*/}}
{{- define "dremio.executor.annotations" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineAnnotations := default (default (default (dict) $context.Values.annotations) $context.Values.executor.annotations) $engineConfiguration.annotations -}}
{{- if $engineAnnotations -}}
annotations:
  {{- toYaml $engineAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Executor - StatefulSet Labels
*/}}
{{- define "dremio.executor.labels" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineLabels := default (default (default (dict) $context.Values.labels) $context.Values.executor.labels) $engineConfiguration.labels -}}
{{- if $engineLabels -}}
labels:
  {{- toYaml $engineLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Annotations
*/}}
{{- define "dremio.executor.podAnnotations" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineAnnotations := default (default (default (dict) $context.Values.podAnnotations) $context.Values.executor.podAnnotations) $engineConfiguration.podAnnotations -}}
{{- if $engineAnnotations -}}
{{ toYaml $engineAnnotations }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Labels
*/}}
{{- define "dremio.executor.podLabels" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineLabels := default (default (default (dict) $context.Values.podLabels) $context.Values.executor.podLabels) $engineConfiguration.podLabels -}}
{{- if $engineLabels -}}
{{ toYaml $engineLabels }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Node Selectors
*/}}
{{- define "dremio.executor.nodeSelector" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineNodeSelector := default (default (default (dict) $context.Values.nodeSelector) $context.Values.executor.nodeSelector) $engineConfiguration.nodeSelector -}}
{{- if $engineNodeSelector -}}
nodeSelector:
  {{- toYaml $engineNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Tolerations
*/}}
{{- define "dremio.executor.tolerations" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineTolerations := default (default (default (dict) $context.Values.tolerations) $context.Values.executor.tolerations) $engineConfiguration.tolerations -}}
{{- if $engineTolerations -}}
tolerations:
  {{- toYaml $engineTolerations | nindent 2 }}
{{- end -}}
{{- end -}}