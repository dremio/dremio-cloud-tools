# Dynamic Executor Auto Scaling

By default, the number of Executors is static. If you would like to enable dynamic auto-scaling based on metrics provided by Prometheus,
enable the Executor Node Lifecycle Service.

### Initial Prometheus Setup


#### Create a Namespace for Prometheus
Create a Namespace for monitoring 

Example:

`kubectl create ns monitoring`

#### Install Prometheus Stack
In order to have the required Custom Resource Definitions (CRD), we will need 
[Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) installed.

Example:
```
# Add the prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n <monitoring namespace> --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
```

#### Install Prometheus Adapter
[Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter) will need to be installed to expose custom scaling metrics

Example:
```
# Add the prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus Adapter
helm install prometheus-adapter prometheus-community/prometheus-adapter -n <monitoring namespace> --set prometheus.port=9090 --set prometheus.url=http://prometheus-operated.<monitoring namespace>.svc
```

#### Install Metrics Server
In order to use the default scaling metrics of CPU and memory usage, [metrics server](https://github.com/kubernetes-sigs/metrics-server) will need to be installed

```
# Add the kubernetes-sigs repo
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install Metrics Server
helm install  metrics-server metrics-server/metrics-server -n <monitoring namespace>
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