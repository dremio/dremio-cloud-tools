# Dynamic Executor Auto Scaling

By default, the number of Executors is static and can only be changed by modifying your Helm Release of Dremio.
We can enable dynamic auto-scaling of the number of Executors based on CPU and memory utilization or JMX metrics.
This feature uses a
[Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
to gather metrics from the Kubernetes cluster to determine if the number of Executors should be adjusted.

### Minimum Requirements
* Helm Version 3.13+
* Dremio Version 24.3+

### Required Setup

#### Create a Namespace for Prometheus
Create a Namespace for monitoring

Example:

`kubectl create ns my-monitoring-ns`

#### Install Prometheus Stack
In order to have the required Custom Resource Definitions (CRD), we will need
[Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) installed.

Example:
```
# Add the prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n my-monitoring-ns --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
```

#### Install Prometheus Adapter
[Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter) will need to be installed to expose JMX metrics from the Executors

Example:
```
# Add the prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus Adapter
helm install prometheus-adapter prometheus-community/prometheus-adapter -n my-monitoring-ns --set prometheus.port=9090 --set prometheus.url=http://prometheus-operated.my-monitoring-ns.svc
```

#### Install Metrics Server
In order to use the default scaling metrics of CPU and memory usage, [metrics server](https://github.com/kubernetes-sigs/metrics-server) will need to be installed
***Note:*** Depending on the cloud vendor, metrics server might already be installed in the Kubernetes cluster.

```
# Add the kubernetes-sigs repo
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install Metrics Server
helm install  metrics-server metrics-server/metrics-server -n my-monitoring-ns
```

Once the initial setup is completed, the Executor Node Lifecycle Service can be enabled in `values.yaml`. See `Values-Reference` for more in depth information.

Example of a basic configuration to enable the Executor Node Lifecycle Service:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    scalingMetrics:
      default:
        enabled: true
    scalingBehavior:
      scaleDown:
        defaultPolicy:
          enabled: true
      scaleUp:
        defaultPolicy:
          enabled: true
  [...]
```

More detailed information about configuration options can be found in the
[Values Reference README](https://github.com/dremio/dremio-cloud-tools/blob/master/charts/dremio_v2/docs/Values-Reference.md)