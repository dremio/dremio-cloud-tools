{{/*
Dremio Storage Class - Provisioner
*/}}
{{- define "dremio.storageClass.provisioner" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{- if eq $provider "gcp" -}}
filestore.csi.storage.gke.io
{{- else if eq $provider "aws" -}}
efs.csi.aws.com
{{- else if eq $provider "azure" -}}
file.csi.azure.com
{{- end -}}
{{- end -}}

{{/*
Dremio Storage Class - Parameters
*/}}
{{- define "dremio.storageClass.params" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{ if eq $provider "aws" }}
fileSystemId: {{ $.Values.masterCoordinator.persistentStorage.parameters.fileSystemId }}
provisioningMode: efs-ap
directoryPerms: "755"
{{ else if eq $provider "azure" }}
protocol: nfs
{{- end -}}
{{- end -}}

{{/**/}}
{{/*Dremio Storage Class - Mount Options*/}}
{{/**/}}
{{- define "dremio.storageClass.mountOptions" -}}
{{- $mountOptions := (($.Values.masterCoordinator).persistentStorage).mountOptions -}}
{{ if $mountOptions }}
mountOptions:
  {{- toYaml $mountOptions | nindent 2 -}}
{{- end -}}
{{- end -}}
