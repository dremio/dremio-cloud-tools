# Dynamic Executor Auto Scaling

By default, the number of Executors is static. If you would like to enable dynamic auto-scaling based on metrics provided by Prometheus,
enable the Executor Node Lifecycle Service.

### Prerequisites
* [Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter#installation) must be installed in the cluster

Once Prometheus Adapter is installed, the Executor Node Lifecycle Service can be enabled in `values.yaml`. See `Values-Reference`
for more in depth information.

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