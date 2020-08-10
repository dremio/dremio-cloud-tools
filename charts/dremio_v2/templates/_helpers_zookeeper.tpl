{{/*
Zookeeper - Storage Class
*/}}
{{- define "dremio.zookeeper.storageClass" -}}
{{- $zookeeperStorageClass := default (default (dict) $.Values.storageClass) $.Values.zookeeper.storageClass -}}
{{- if $zookeeperStorageClass -}}
storageClass: {{ $zookeeperStorageClass }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - StatefulSet Annotations
*/}}
{{- define "dremio.zookeeper.annotations" -}}
{{- $zookeeperAnnotations := default (default (dict) $.Values.annotations) $.Values.zookeeper.annotations -}}
{{- if $zookeeperAnnotations -}}
annotations:
  {{- toYaml $zookeeperAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - StatefulSet Labels
*/}}
{{- define "dremio.zookeeper.labels" -}}
{{- $zookeeperLabels := default (default (dict) $.Values.labels) $.Values.zookeeper.labels -}}
{{- if $zookeeperLabels -}}
labels:
  {{- toYaml $zookeeperLabels | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Annotations
*/}}
{{- define "dremio.zookeeper.podAnnotations" -}}
{{- $coordiantorAnnotations := default (default (dict) $.Values.podAnnotations) $.Values.zookeeper.podAnnotations -}}
{{- if $coordiantorAnnotations -}}
annotations:
  {{- toYaml $coordiantorAnnotations | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Labels
*/}}
{{- define "dremio.zookeeper.podLabels" -}}
{{- $zookeeperLabels := default (default (dict) $.Values.podLabels) $.Values.zookeeper.podLabels -}}
{{- if $zookeeperLabels -}}
{{ toYaml $zookeeperLabels }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Node Selectors
*/}}
{{- define "dremio.zookeeper.nodeSelector" -}}
{{- $zookeeperNodeSelector := default (default (dict) $.Values.nodeSelector) $.Values.zookeeper.nodeSelector -}}
{{- if $zookeeperNodeSelector -}}
nodeSelector:
  {{- toYaml $zookeeperNodeSelector | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper - Pod Tolerations
*/}}
{{- define "dremio.zookeeper.tolerations" -}}
{{- $zookeeperTolerations := default (default (dict) $.Values.tolerations) $.Values.zookeeper.tolerations -}}
{{- if $zookeeperTolerations -}}
tolerations:
  {{- toYaml $zookeeperTolerations | nindent 2 }}
{{- end -}}
{{- end -}}