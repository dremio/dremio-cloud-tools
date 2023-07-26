{{/*
HPA - Minimum and Maximum Number of Executors
*/}}
{{ define "dremio.hpa.executorReplicaCounts" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
minReplicas: {{ default 1 $nodeLifecycleServiceConfig.minExecutors }}
maxReplicas: {{ default 50 $nodeLifecycleServiceConfig.maxExecutors }}
{{- end -}}

{{/*
HPA - Default Scaling based on CPU and Memory
*/}}
{{- define "dremio.hpa.scaleMetrics.defaults" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
{{- $defaultScalingMetricsConfig := $nodeLifecycleServiceConfig.scalingMetrics.default -}}
{{ if $defaultScalingMetricsConfig.enabled }}
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
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
{{- $userDefinedMetrics := $nodeLifecycleServiceConfig.scalingMetrics.userDefinedMetrics -}}
{{- if $userDefinedMetrics -}}
{{ toYaml $userDefinedMetrics }}
{{- end -}}
{{- end -}}

{{/*
HPA - Default ScaleDown Policy
*/}}
{{- define "dremio.hpa.behavior.scaleDown.policies.default" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
{{- $scaleDownConfig := $nodeLifecycleServiceConfig.scalingBehavior.scaleDown.defaultPolicy -}}
{{ if $scaleDownConfig.enabled }}
- type: Percent
  value: {{ $scaleDownConfig.value | default 100 }}
  periodSeconds: {{ $scaleDownConfig.periodSeconds | default 60 }}
{{- end -}}
{{- end -}}

{{/*
HPA - User Defined ScaleDown Policies
*/}}
{{- define "dremio.hpa.behavior.scaleDown.policies.userDefined" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
{{- $userDefinedPolicies := $nodeLifecycleServiceConfig.scalingBehavior.scaleDown.userDefinedPolicies -}}
{{ if $userDefinedPolicies }}
{{ toYaml $userDefinedPolicies }}
{{- end -}}
{{- end -}}

{{/*
HPA - Default ScaleUp Policy
*/}}
{{- define "dremio.hpa.behavior.scaleUp.policies.default" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
{{- $scaleUpConfig := $nodeLifecycleServiceConfig.scalingBehavior.scaleUp.defaultPolicy -}}
{{ if $scaleUpConfig.enabled }}
- type: Percent
  value: {{ $scaleUpConfig.value | default 1 }}
  periodSeconds: {{ $scaleUpConfig.periodSeconds | default 600 }}
{{- end -}}
{{- end -}}

{{/*
HPA - User Defined ScaleUp Policies
*/}}
{{- define "dremio.hpa.behavior.scaleUp.policies.userDefined" -}}
{{- $context := index . 0 -}}
{{- $engineName := index . 1 -}}
{{- $engineConfiguration := default (dict) (get (default (dict) $context.Values.executor.engineOverride) $engineName) -}}
{{- $nodeLifecycleServiceConfig := coalesce $engineConfiguration.nodeLifecycleService $context.Values.executor.nodeLifecycleService -}}
{{- $userDefinedPolicies := $nodeLifecycleServiceConfig.scalingBehavior.scaleUp.userDefinedPolicies -}}
{{ if $userDefinedPolicies }}
{{ toYaml $userDefinedPolicies }}
{{- end -}}
{{- end -}}