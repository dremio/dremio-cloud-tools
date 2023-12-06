{{/*
Automated Back Ups -  Distributed Storage
*/}}
{{- define "dremio.automatedBackups.distStorage" -}}
{{- if eq $.Values.distStorage.type "aws" -}}
dremioS3:///{{ $.Values.distStorage.aws.bucketName }}/{{ $.Values.distStorage.aws.path }}/backups
{{ else if eq $.Values.distStorage.type "gcp" }}
dremiogcs:///{{ $.Values.distStorage.gcp.bucketName }}/{{ $.Values.distStorage.gcp.path }}/backups
{{ else if eq $.Values.distStorage.type "azureStorage" }}
dremioAzureStorage://:///{{ $.Values.distStorage.azureStorage.filesystem }}/{{ $.Values.distStorage.azureStorage.path }}/backups
{{- else -}}
{{ fail "Invalid Distributed Storage Configuration " }}
{{- end -}}
{{- end -}}
