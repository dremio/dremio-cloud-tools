
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
{{- $engineMemory -}}Mi
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
Executor - Service Account
*/}}
{{- define "dremio.executor.serviceAccount" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineServiceAccount := coalesce $engineConfiguration.serviceAccount $context.Values.executor.serviceAccount $context.Values.serviceAccount -}}
{{- if $engineServiceAccount -}}
serviceAccountName: {{ $engineServiceAccount }}
{{- end -}}
{{- end -}}

{{/*
Executor - Dremio Start Parameters
*/}}
{{- define "dremio.executor.extraStartParams" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineExtraStartParams := coalesce $engineConfiguration.extraStartParams $context.Values.executor.extraStartParams $context.Values.extraStartParams -}}
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
{{- $engineExtraInitContainers := coalesce $engineConfiguration.extraInitContainers $context.Values.executor.extraInitContainers $context.Values.extraInitContainers -}}
{{- if $engineExtraInitContainers -}}
{{ tpl $engineExtraInitContainers $context }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Extra Volume Mounts
*/}}
{{- define "dremio.executor.extraVolumeMounts" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineExtraVolumeMounts := coalesce $engineConfiguration.extraVolumeMounts $context.Values.executor.extraVolumeMounts $context.Values.extraVolumeMounts -}}
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
{{- $engineExtraVolumes := coalesce $engineConfiguration.extraVolumes $context.Values.executor.extraVolumes $context.Values.extraVolumes -}}
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
{{- $engineStorageClass := coalesce $engineConfiguration.storageClass $context.Values.executor.storageClass $context.Values.storageClass -}}
{{- if $engineStorageClass -}}
storageClassName: {{ $engineStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Executor - Cloud Cache Peristent Volume Claims
*/}}
{{- define "dremio.executor.cloudCache.volumeClaimTemplate" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineCloudCacheConfig := default (dict) $engineConfiguration.cloudCache -}}
{{- $cloudCacheConfig := coalesce $engineConfiguration.cloudCache $context.Values.executor.cloudCache -}}
{{- $cloudCacheStorageClass := coalesce $engineCloudCacheConfig.storageClass $context.Values.executor.cloudCache.storageClass $engineConfiguration.storageClass $context.Values.executor.storageClass $context.Values.storageClass -}}
{{- if $cloudCacheConfig.enabled -}}
{{- range $index, $cloudCacheVolumeConfig := $cloudCacheConfig.volumes }}
{{- $volumeStorageClass := coalesce $cloudCacheVolumeConfig.storageClass $cloudCacheStorageClass }}
- metadata:
    name: {{ coalesce $cloudCacheVolumeConfig.name (printf "dremio-%s-executor-c3-%d" $engineName $index) }}
  spec:
    accessModes: ["ReadWriteOnce"]
    {{- if $volumeStorageClass }}
    storageClassName: {{ $volumeStorageClass }}
    {{- end }}
    resources:
      requests:
        storage: {{ $cloudCacheVolumeConfig.size }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Executor - Cloud Cache Peristent Volume Mounts
*/}}
{{- define "dremio.executor.cloudCache.volumeMounts" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $cloudCacheConfig := coalesce $engineConfiguration.cloudCache $context.Values.executor.cloudCache -}}
{{- if $cloudCacheConfig.enabled -}}
{{- range $index, $cloudCacheVolumeConfig := $cloudCacheConfig.volumes }}
- name: {{ coalesce $cloudCacheVolumeConfig.name (printf "dremio-%s-executor-c3-%d" $engineName $index) }}
  mountPath: /opt/dremio/cloudcache/c{{ $index }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Executor - Cloud Cache Peristent Volume Mounts
*/}}
{{- define "dremio.executor.cloudCache.initContainers" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $cloudCacheConfig := coalesce $engineConfiguration.cloudCache $context.Values.executor.cloudCache -}}
{{- if $cloudCacheConfig.enabled -}}
- name: chown-cloudcache-directory
  image: {{ $context.Values.image }}:{{ $context.Values.imageTag }}
  imagePullPolicy: IfNotPresent
  securityContext:
    runAsUser: 0
  volumeMounts:
  {{- include "dremio.executor.cloudCache.volumeMounts" (list $context $engineName) | nindent 2 }}
  command: ["bash"]
  args: ["-c", "chown dremio:dremio /opt/dremio/cloudcache/c*"]
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
{{- $engineAnnotations := coalesce $engineConfiguration.annotations $context.Values.executor.annotations $context.Values.annotations -}}
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
{{- $engineLabels := coalesce $engineConfiguration.labels $context.Values.executor.labels $context.Values.labels -}}
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
{{- $enginePodAnnotations := coalesce $engineConfiguration.podAnnotations $context.Values.executor.podAnnotations $context.Values.podAnnotations -}}
{{- if $enginePodAnnotations -}}
{{ toYaml $enginePodAnnotations }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Labels
*/}}
{{- define "dremio.executor.podLabels" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $enginePodLabels := coalesce $engineConfiguration.podLabels $context.Values.executor.podLabels $context.Values.podLabels -}}
{{- if $enginePodLabels -}}
{{ toYaml $enginePodLabels }}
{{- end -}}
{{- end -}}

{{/*
Executor - Pod Node Selectors
*/}}
{{- define "dremio.executor.nodeSelector" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $engineNodeSelector := coalesce $engineConfiguration.nodeSelector $context.Values.executor.nodeSelector $context.Values.nodeSelector -}}
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
{{- $engineTolerations := coalesce $engineConfiguration.tolerations $context.Values.executor.tolerations $context.Values.tolerations -}}
{{- if $engineTolerations -}}
tolerations:
  {{- toYaml $engineTolerations | nindent 2 }}
{{- end -}}
{{- end -}}