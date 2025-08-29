{{/*
Coordinator - Dremio Heap Memory allocation
*/}}
{{- define "dremio.coordinator.heapMemory" -}}
{{- $coordinatorMemory := int $.Values.coordinator.memory -}}
{{- $reserveMemory := 0 -}}
{{- if gt 4096 $coordinatorMemory -}}
{{ fail "Dremio's minimum memory requirement is 4 GB." }}
{{- end -}}
{{- if le 64000 $coordinatorMemory -}}
{{- $reserveMemory = 6000 -}}
{{- else -}}
{{- $reserveMemory = mulf $coordinatorMemory .05 | int -}}
{{- end -}}
{{- $coordinatorMemory = sub $coordinatorMemory $reserveMemory}}
{{- if le 18432 $coordinatorMemory -}}
16384
{{- else -}}
{{- sub $coordinatorMemory 2048}}
{{- end -}}
{{- end -}}

{{/*
Coordiantor - Dremio Direct Memory Allocation
*/}}
{{- define "dremio.coordinator.directMemory" -}}
{{- $coordinatorMemory := int $.Values.coordinator.memory -}}
{{- $reserveMemory := 0 -}}
{{- if gt 4096 $coordinatorMemory -}}
{{ fail "Dremio's minimum memory requirement is 4 GB." }}
{{- end -}}
{{- if le 64000 $coordinatorMemory -}}
{{- $reserveMemory = 6000 -}}
{{- else -}}
{{- $reserveMemory = mulf $coordinatorMemory .05 | int -}}
{{- end -}}
{{- $coordinatorMemory = sub $coordinatorMemory $reserveMemory}}
{{- if le 18432 $coordinatorMemory -}}
{{- sub $coordinatorMemory 16384 -}}
{{- else -}}
2048
{{- end -}}
{{- end -}}

{{/*
Coordinator - Service Account
*/}}
{{- define "dremio.coordinator.serviceAccount" -}}
{{- $coordinatorServiceAccount := coalesce $.Values.coordinator.serviceAccount $.Values.serviceAccount -}}
{{- if $coordinatorServiceAccount -}}
serviceAccountName: {{ $coordinatorServiceAccount }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Dremio Start Parameters
*/}}
{{- define "dremio.coordinator.extraStartParams" -}}
{{- $coordinatorExtraStartParams := coalesce $.Values.coordinator.extraStartParams $.Values.extraStartParams -}}
{{- if $coordinatorExtraStartParams}}
{{- printf "%v " $coordinatorExtraStartParams -}}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Extra Init Containers
*/}}
{{- define "dremio.coordinator.extraInitContainers" -}}
{{- $coordinatorExtraInitContainers := coalesce $.Values.coordinator.extraInitContainers $.Values.extraInitContainers -}}
{{- if $coordinatorExtraInitContainers -}}
{{ tpl $coordinatorExtraInitContainers $ }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Container Extra Environment Variables
*/}}
{{- define "dremio.coordinator.extraEnvs" -}}
{{- $coordinatorEnvironmentVariables := default (default (dict) $.Values.extraEnvs) $.Values.coordinator.extraEnvs -}}
{{- range $index, $environmentVariable:= $coordinatorEnvironmentVariables -}}
{{- if hasPrefix "DREMIO" $environmentVariable.name -}}
{{ fail "Environment variables cannot begin with DREMIO"}}
{{- end -}}
{{- end -}}
{{- if $coordinatorEnvironmentVariables -}}
{{ toYaml $coordinatorEnvironmentVariables }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Log Path
*/}}
{{- define "dremio.coordinator.log.path" -}}
{{- $writeLogsToFile := include "dremio.booleanCoalesce" (list $.Values.coordinator.writeLogsToFile $.Values.writeLogsToFile nil) -}}
{{- if $writeLogsToFile -}}
- name: DREMIO_LOG_TO_CONSOLE
  value: "0"
- name: DREMIO_LOG_DIR
  value: /opt/dremio/log
{{- else -}}
- name: DREMIO_LOG_TO_CONSOLE
  value: "1"
{{- end -}}
{{- end -}}

{{/*
Coordinator - Log Volume Mount
*/}}
{{- define "dremio.coordinator.log.volumeMount" -}}
{{- $writeLogsToFile := include "dremio.booleanCoalesce" (list $.Values.coordinator.writeLogsToFile $.Values.writeLogsToFile nil) -}}
{{- if $writeLogsToFile -}}
- name: dremio-log-volume
  mountPath: /opt/dremio/log
{{- end -}}
{{- end -}}

{{/*
Coordinator - Logs Volume Claim Template
*/}}
{{- define "dremio.coordinator.log.volumeClaimTemplate" -}}
{{- $coordinatorLogStorageClass := coalesce $.Values.coordinator.logStorageClass $.Values.logStorageClass -}}
{{- $writeLogsToFile := include "dremio.booleanCoalesce" (list $.Values.coordinator.writeLogsToFile $.Values.writeLogsToFile nil) -}}
{{- if $writeLogsToFile -}}
- metadata:
    name: dremio-log-volume
  spec:
    accessModes: ["ReadWriteOnce"]
    {{ include "dremio.coordinator.log.storageClass" $ }}
    resources:
      requests:
        storage: {{ $.Values.coordinator.volumeSize }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Extra Volume Mounts
*/}}
{{- define "dremio.coordinator.extraVolumeMounts" -}}
{{- $coordinatorExtraVolumeMounts := default (default (dict) $.Values.extraVolumeMounts) $.Values.coordinator.extraVolumeMounts -}}
{{- if $coordinatorExtraVolumeMounts -}}
{{ toYaml $coordinatorExtraVolumeMounts }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Extra Volumes
*/}}
{{- define "dremio.coordinator.extraVolumes" -}}
{{- $coordinatorExtraVolumes := coalesce $.Values.coordinator.extraVolumes $.Values.extraVolumes -}}
{{- if $coordinatorExtraVolumes -}}
{{ toYaml $coordinatorExtraVolumes }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Storage Class
*/}}
{{- define "dremio.coordinator.storageClass" -}}
{{- $coordinatorStorageClass := coalesce $.Values.coordinator.storageClass $.Values.storageClass -}}
{{- if $coordinatorStorageClass -}}
storageClassName: {{ $coordinatorStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Logs Storage Class
*/}}
{{- define "dremio.coordinator.log.storageClass" -}}
{{- $coordinatorLogStorageClass := $.Values.coordinator.logStorageClass -}}
{{- if $coordinatorLogStorageClass -}}
storageClassName: {{ $coordinatorLogStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - StatefulSet Annotations
*/}}
{{- define "dremio.coordinator.annotations" -}}
{{- $coordinatorAnnotations := coalesce $.Values.coordinator.annotations $.Values.annotations -}}
{{- if $coordinatorAnnotations -}}
annotations:
  {{- toYaml $coordinatorAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - StatefulSet Labels
*/}}
{{- define "dremio.coordinator.labels" -}}
{{- $coordinatorLabels := coalesce $.Values.coordinator.labels $.Values.labels -}}
{{- if $coordinatorLabels -}}
labels:
  {{- toYaml $coordinatorLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Annotations
*/}}
{{- define "dremio.coordinator.podAnnotations" -}}
{{- $coordiantorPodAnnotations := coalesce $.Values.coordinator.podAnnotations $.Values.podAnnotations -}}
{{- if $coordiantorPodAnnotations -}}
{{ toYaml $coordiantorPodAnnotations }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Labels
*/}}
{{- define "dremio.coordinator.podLabels" -}}
{{- $coordinatorPodLabels := coalesce $.Values.coordinator.podLabels $.Values.podLabels -}}
{{- if $coordinatorPodLabels -}}
{{ toYaml $coordinatorPodLabels }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Node Selectors
*/}}
{{- define "dremio.coordinator.nodeSelector" -}}
{{- $coordinatorNodeSelector := coalesce $.Values.coordinator.nodeSelector $.Values.nodeSelector -}}
{{- if $coordinatorNodeSelector -}}
nodeSelector:
  {{- toYaml $coordinatorNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Tolerations
*/}}
{{- define "dremio.coordinator.tolerations" -}}
{{- $coordinatorTolerations := coalesce $.Values.coordinator.tolerations $.Values.tolerations -}}
{{- if $coordinatorTolerations -}}
tolerations:
  {{- toYaml $coordinatorTolerations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Active Processor Count
*/}}
{{- define "dremio.coordinator.activeProcessorCount" -}}
{{- $coordinatorCpu := floor $.Values.coordinator.cpu | int -}}
{{- if gt 1 $coordinatorCpu -}}
1
{{- else -}}
{{- $coordinatorCpu -}}
{{- end -}}
{{- end -}}
