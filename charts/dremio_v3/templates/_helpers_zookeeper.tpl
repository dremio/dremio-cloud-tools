{{/*
Zookeeper - Memory Calculation
*/}}
{{- define "dremio.zookeeper.memory" -}}
{{- $heapMemory := sub (int $.Values.zookeeper.memory) 100 -}}
{{- $heapMemory -}}
{{- end -}}

{{/*
Zookeeper - Storage Class
*/}}
{{- define "dremio.zookeeper.storageClass" -}}
{{- $zookeeperStorageClass := coalesce $.Values.zookeeper.storageClass $.Values.storageClass -}}
{{- if $zookeeperStorageClass -}}
storageClassName: {{ $zookeeperStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Service Account
*/}}
{{- define "dremio.zookeeper.serviceAccount" -}}
{{- $zookeeperServiceAccount := coalesce $.Values.zookeeper.serviceAccount $.Values.serviceAccount -}}
{{- if $zookeeperServiceAccount -}}
serviceAccountName: {{ $zookeeperServiceAccount }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - StatefulSet Annotations
*/}}
{{- define "dremio.zookeeper.annotations" -}}
{{- $zookeeperAnnotations := coalesce $.Values.zookeeper.annotations $.Values.annotations -}}
{{- if $zookeeperAnnotations -}}
annotations:
  {{- toYaml $zookeeperAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - StatefulSet Labels
*/}}
{{- define "dremio.zookeeper.labels" -}}
{{- $zookeeperLabels := coalesce $.Values.zookeeper.labels $.Values.labels -}}
{{- if $zookeeperLabels -}}
labels:
  {{- toYaml $zookeeperLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Annotations
*/}}
{{- define "dremio.zookeeper.podAnnotations" -}}
{{- $coordiantorAnnotations := coalesce $.Values.zookeeper.podAnnotations $.Values.podAnnotations -}}
{{- if $coordiantorAnnotations -}}
annotations:
  {{- toYaml $coordiantorAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Labels
*/}}
{{- define "dremio.zookeeper.podLabels" -}}
{{- $zookeeperLabels := coalesce $.Values.zookeeper.podLabels $.Values.podLabels -}}
{{- if $zookeeperLabels -}}
{{ toYaml $zookeeperLabels }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Node Selectors
*/}}
{{- define "dremio.zookeeper.nodeSelector" -}}
{{- $zookeeperNodeSelector := coalesce $.Values.zookeeper.nodeSelector $.Values.nodeSelector -}}
{{- if $zookeeperNodeSelector -}}
nodeSelector:
  {{- toYaml $zookeeperNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Tolerations
*/}}
{{- define "dremio.zookeeper.tolerations" -}}
{{- $zookeeperTolerations := coalesce $.Values.zookeeper.tolerations $.Values.tolerations -}}
{{- if $zookeeperTolerations -}}
tolerations:
  {{- toYaml $zookeeperTolerations | nindent 2 }}
{{- end -}}
{{- end -}}