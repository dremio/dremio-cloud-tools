{{/*
Coordinator - Dremio Heap Memory allocation
*/}}
{{- define "dremio.coordinator.heapMemory" -}}
{{- $coordinatorMemory := int $.Values.coordinator.memory -}}
{{- if gt 4096 $coordinatorMemory -}}
{{ fail "Dremio's minimum memory requirement is 4 GB." }}
{{- end -}}
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
{{- if gt 4096 $coordinatorMemory -}}
{{ fail "Dremio's minimum memory requirement is 4 GB." }}
{{- end -}}
{{- if le 18432 $coordinatorMemory -}}
{{- sub $coordinatorMemory 16384 -}}
{{- else -}}
2048
{{- end -}}
{{- end -}}

{{/*
Coordinator - Dremio Start Parameters
*/}}
{{- define "dremio.coordinator.extraStartParams" -}}
{{- $coordinatorExtraStartParams := default (default "" $.Values.extraStartParams) $.Values.coordinator.extraStartParams -}}
{{- if $coordinatorExtraStartParams}}
{{- printf "%v " $coordinatorExtraStartParams -}}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Extra Init Containers
*/}}
{{- define "dremio.coordinator.extraInitContainers" -}}
{{- $coordinatorExtraInitContainers := default (default (dict) $.Values.extraInitContainers) $.Values.coordinator.extraInitContainers -}}
{{- if $coordinatorExtraInitContainers -}}
{{ tpl $coordinatorExtraInitContainers $ }}
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
{{- $coordinatorExtraVolumes := default (default (dict) $.Values.extraVolumes) $.Values.coordinator.extraVolumes -}}
{{- if $coordinatorExtraVolumes -}}
{{ toYaml $coordinatorExtraVolumes }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Storage Class
*/}}
{{- define "dremio.coordinator.storageClass" -}}
{{- $coordinatorStorageClass := default (default (dict) $.Values.storageClass) $.Values.coordinator.storageClass -}}
{{- if $coordinatorStorageClass -}}
storageClass: {{ $coordinatorStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - StatefulSet Annotations
*/}}
{{- define "dremio.coordinator.annotations" -}}
{{- $coordinatorAnnotations := default (default (dict) $.Values.annotations) $.Values.coordinator.annotations -}}
{{- if $coordinatorAnnotations -}}
annotations:
  {{- toYaml $coordinatorAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - StatefulSet Labels
*/}}
{{- define "dremio.coordinator.labels" -}}
{{- $coordinatorLabels := default (default (dict) $.Values.labels) $.Values.coordinator.labels -}}
{{- if $coordinatorLabels -}}
labels:
  {{- toYaml $coordinatorLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Annotations
*/}}
{{- define "dremio.coordinator.podAnnotations" -}}
{{- $coordiantorAnnotations := default (default (dict) $.Values.podAnnotations) $.Values.coordinator.podAnnotations -}}
{{- if $coordiantorAnnotations -}}
{{ toYaml $coordiantorAnnotations }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Labels
*/}}
{{- define "dremio.coordinator.podLabels" -}}
{{- $coordinatorLabels := default (default (dict) $.Values.podLabels) $.Values.coordinator.podLabels -}}
{{- if $coordinatorLabels -}}
{{ toYaml $coordinatorLabels }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Node Selectors
*/}}
{{- define "dremio.coordinator.nodeSelector" -}}
{{- $coordinatorNodeSelector := default (default (dict) $.Values.nodeSelector) $.Values.coordinator.nodeSelector -}}
{{- if $coordinatorNodeSelector -}}
nodeSelector:
  {{- toYaml $coordinatorNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Coordinator - Pod Tolerations
*/}}
{{- define "dremio.coordinator.tolerations" -}}
{{- $coordinatorTolerations := default (default (dict) $.Values.tolerations) $.Values.coordinator.tolerations -}}
{{- if $coordinatorTolerations -}}
tolerations:
  {{- toYaml $coordinatorTolerations | nindent 2 }}
{{- end -}}
{{- end -}}