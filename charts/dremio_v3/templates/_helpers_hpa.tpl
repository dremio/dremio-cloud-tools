{{/*
HPA - Minimum and Maximum Number of Executors
*/}}
{{ define "dremio.hpa.executorReplicaCounts" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.executorNodeLifecycleService) $engineName) -}}
{{- $minExecutors := default 1 coalesce $engineConfiguration.minExecutors $context.Values.executor.nodeLifecycleService.minExecutors  -}}
{{- $maxExecutors := default 50 coalesce $engineConfiguration.maxExecutors $context.Values.executor.nodeLifecycleService.maxExecutors -}}
minReplicas: {{ $minExecutors }}
maxExecutors: {{ $maxExecutors }}
{{- end -}}

** COME BACK HERE NOT EVERYTHING WITH defaultScalingMetricsConfig.enabled checks

{{/*
HPA - Default Scaling based on CPU and Memory
*/}}
{{- define "dremio.hpa.scaleMetrics.defaults" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.executorNodeLifecycleService) $engineName) -}}
{{- $defaultScalingMetricsConfig := coalesce $engineConfiguration.defaultScalingMetricsConfig $context.Values.executor.nodeLifecycleService.defaultScalingMetricsConfig -}}
{{- $isEnabled := default true $defaultScalingMetricsConfig.enabled -}}
{{- if $defaultScalingMetricsConfig.enabled -}}
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: {{ $defaultScalingMetricsConfig.cpuAverageUtilization | default 70 }}
- type: Resource
  resource:
    name: memory
    target:
      type: Utilization
      averageUtilization: {{ $defaultScalingMetricsConfig.memoryAverageUtilization | default 70 }}
{{- end -}}
{{- end -}}

{{/*
HPA - User Defined Scaling Metrics
*/}}
{{- define "dremio.hpa.scaleMetrics.userDefined" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.executorNodeLifecycleService) $engineName) -}}
{{- $userDefinedScalingMetricsConfig := coalesce $engineConfiguration.userDefinedScalingMetricsConfig $context.Values.executor.nodeLifecycleService.userDefinedScalingMetricsConfig -}}
{{- if $userDefinedScalingMetricsConfig -}}
{{ toYaml $userDefinedScalingMetricsConfig }}
{{- end -}}
{{- end -}}

