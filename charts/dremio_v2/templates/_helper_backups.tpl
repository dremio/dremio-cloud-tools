{{/*
Back Ups -  Distributed Store
*/}}
{{- define "dremio.backups.distStorage" -}}
{{- if eq $.Values.distStorage.type "aws" -}}
dremioS3:///{{ $.Values.distStorage.aws.bucketName }}/backups
{{ else if eq $.Values.distStorage.type "gcp" }}
dremiogcs:///{{ $.Values.distStorage.gcp.bucketName }}/backups
{{ else if eq $.Values.distStorage.type "azure" }}
dremioAzureStorage:///{{ $.Values.distStorage.azure.datalakeStoreName }}/backups
{{- else -}}
{{ fail "Invalid Distributed Storage Configuration " }}
{{- end -}}
{{- end -}}
