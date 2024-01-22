{{/*
Dremio Storage Class - Provisioner
*/}}
{{- define "dremio.storageClass.provisioner" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{- if eq $provider "azure" -}}
file.csi.azure.com
{{- else if eq $provider "gcp" -}}
filestore.csi.storage.gke.io
{{- else if eq $provider "aws" -}}
efs.csi.aws.com
{{- end -}}
{{- end -}}

{{/*
Dremio Storage Class - Parameters
*/}}
{{- define "dremio.storageClass.params" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{- $awsFileSystemId := ((($.Values.masterCoordinator).persistentStorage).parameters).awsFileSystemId -}}
{{- if eq $provider "aws" }}
provisioningMode: efs-ap
directoryPerms: "700"
fileSystemId: {{ $awsFileSystemId }}
{{- end -}}
{{- end -}}

{{/*
Dremio Storage Class - Mount Options
*/}}
{{- define "dremio.storageClass.mountOptions" -}}
{{- $provider := (($.Values.masterCoordinator).persistentStorage).provider -}}
{{- if eq $provider "azure" -}}
mountOptions:
  - uid=6715
  - gid=6715
{{- end -}}
{{- end -}}
