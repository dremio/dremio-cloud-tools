{{/*
Back Ups -  Distributed Store
*/}}
{{- define "dremio.backups.distStorage" -}}
{{- if eq $.Values.distStorage.type "aws" -}}
dremioS3:///{{ $.Values.distStorage.aws.bucketName }}/fakebucket
{{- end -}}
{{- end -}}
