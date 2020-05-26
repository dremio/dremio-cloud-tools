{{/*
Expand the name of the chart.
*/}}
{{- define "dremio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "dremio.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Calcuate the heap memory used by Dremio
*/}}
{{- define "HeapMemory" -}}
{{- $input := int . -}}
{{- if ge $input 32768 -}}
8192
{{- else if ge $input 16384 -}}
4096
{{- else if ge $input 4096 -}}
2048
{{- else -}}
{{- div $input 4 -}}
{{- end -}}
{{- end -}}

{{/*
Calcuate the direct memory used by Dremio
*/}}
{{- define "DirectMemory" -}}
{{- $input := int . -}}
{{- if ge $input 32768 -}}
{{ sub $input 8192 }}
{{- else if ge $input 16384 -}}
{{ sub $input 4096 }}
{{- else if ge $input 4096 -}}
{{ sub $input 2048 }}
{{- else -}}
{{- $t1 := div $input 4 -}}
{{- sub $input $t1 -}}
{{- end -}}
{{- end -}}

{{/*
Calcuate the memory thresholds for the hpa scaling
*/}}
{{- define "MemoryScaler" -}}
{{- $input := int . -}}
{{- $t1 := div $input 2 -}}
{{- sub $input $t1 -}}
{{- end -}}
