{{/*
Dremio Storage Class - Provisioner
*/}}
{{- define "dremio.storageClass.provisioner" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{- if eq $provider "azure" -}}
file.csi.azure.com
{{- else if eq $provider "gcp" -}}
filestore.csi.storage.gke.io
{{- end -}}
{{- end -}}

{{/*
Dremio Storage Class - Parameters
*/}}
{{- define "dremio.storageClass.params" -}}
{{ toYaml $.Values.masterCoordinator.persistentStorage.parameters }}
{{- end -}}

{{/*
Dremio Storage Class - Mount Options
*/}}
{{- define "dremio.storageClass.mountOptions" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{- if eq $provider "azure" -}}
mountOptions:
  - uid=999
  - gid=999
{{- end -}}
{{- end -}}
