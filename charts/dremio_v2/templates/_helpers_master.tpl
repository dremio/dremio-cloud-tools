{{/*
Master Coordinator - Number of Replicas
*/}}
{{- define "dremio.masterCoordinator.replicaCount" -}}
{{- $haEnabled := default false (($.Values.masterCoordinator).highAvailability).enabled -}}
{{- if eq $haEnabled true }}
replicas: 2
{{- else -}}
replicas: 1
{{- end -}}
{{- end -}}

{{/*
Master Coordinator - Dremio Master Coordinator Container StartupProbe
*/}}
{{- define "dremio.masterCoordinator.container.startupProbe" -}}
{{- $haEnabled := default false (($.Values.masterCoordinator).highAvailability).enabled -}}
{{- if eq $haEnabled false }}
startupProbe:
  httpGet:
    path: /
    {{- if $.Values.coordinator.web.tls.enabled }}
    scheme: HTTPS
    {{- end }}
    port: web
  failureThreshold: {{ $.Values.coordinator.startupProbe.failureThreshold }}
  periodSeconds: {{ $.Values.coordinator.startupProbe.periodSeconds }}
{{- end -}}
{{- end -}}

{{/*
Master Coordinator - Dremio Master Coordinator Container Readiness Probe
*/}}
{{- define "dremio.masterCoordinator.container.readinessProbe" -}}
{{- $haEnabled := default false (($.Values.masterCoordinator).highAvailability).enabled -}}
readinessProbe:
  httpGet:
    path: /
    {{- if $.Values.coordinator.web.tls.enabled }}
    scheme: HTTPS
    {{- end }}
    port: web
  {{- if eq $haEnabled false }}
  failureThreshold: {{ $.Values.coordinator.readinessProbe.failureThreshold }}
  {{- end }}
  periodSeconds: {{ $.Values.coordinator.readinessProbe.periodSeconds }}
{{- end -}}

{{/*
Master Coordinator - Start Only One Master Init Container
*/}}
{{- define "dremio.masterCoordinator.initContainers.startOnlyOneMaster" -}}
{{- $haEnabled := default false (($.Values.masterCoordinator).highAvailability).enabled -}}
{{- if eq $haEnabled false }}
- name: start-only-one-dremio-master
  image: busybox
  command: ["sh", "-c", "INDEX=${HOSTNAME##*-}; if [ $INDEX -ne 0 ]; then echo Only one master should be running.; exit 1; fi; "]
{{- end -}}
{{- end -}}

{{/*
Master Coordinator - Upgrade Task Init Container
*/}}
{{- define "dremio.masterCoordinator.initContainers.upgradeTask" -}}
{{- $haEnabled := default false (($.Values.masterCoordinator).highAvailability).enabled -}}
{{- if eq $haEnabled false }}
- name: upgrade-task
  image: {{ $.Values.image }}:{{ $.Values.imageTag }}
  imagePullPolicy: IfNotPresent
  volumeMounts:
  - name: dremio-master-volume
    mountPath: /opt/dremio/data
  - name: dremio-config
    mountPath: /opt/dremio/conf
  command: ["/opt/dremio/bin/dremio-admin"]
  args:
  - "upgrade"
{{- end -}}
{{- end -}}

{{/*
Master Coordinator - Persisent Volume
*/}}
{{- define "dremio.masterCoordinator.volumes.masterVolume" -}}
{{- $persistentStorageProvider := ($.Values.masterCoordinator).persistentStorage -}}
{{- if $persistentStorageProvider -}}
- name: dremio-master-volume
  persistentVolumeClaim:
    claimName: dremio-master-volume
{{- end -}}
{{- end -}}

{{/*
Master Coordinator - Volume Claim Template
*/}}
{{- define "dremio.masterCoordinator.volumesClaimTemplates" -}}
{{- $persistentStorageProvider := ($.Values.masterCoordinator).persistentStorage -}}
{{- if not $persistentStorageProvider }}
volumeClaimTemplates:
- metadata:
    name: dremio-master-volume
  spec:
    accessModes: ["ReadWriteOnce"]
    {{- include "dremio.coordinator.storageClass" $ | nindent 6 }}
    resources:
      requests:
        storage: {{ $.Values.coordinator.volumeSize }}
{{- end -}}
{{- end -}}
