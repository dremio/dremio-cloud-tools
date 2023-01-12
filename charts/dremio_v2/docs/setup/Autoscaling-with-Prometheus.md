# Autoscaling Dremio Executors Based on Prometheus Metrics
The number of Dremio Executors can be autoscaled based on metrics that are exposed by Prometheus.

### Prerequisites
* [Prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus) and [Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter) must be installed in the Kubernetes cluster

### Configuration
All configurations for auto scaling will be controlled in `values.yaml`. The changes that are required to `values.yaml` are as follows:

* `executor.extraPorts` - a port for Prometheus to scrape metrics from must be included. eg:
    ```
    - containerPort: 9010
      name: prometheus
      protocol: TCP
    ```

* `executor.extraStartParams` - Additional start parameters will need to be supplied to Dremio

    ```
    extraStartParams: >-
      -Dservices.web-admin.port=9010
      -Dservices.web-admin.enabled=true
      -Dservices.web-admin.host=0.0.0.0
    ```

* `executor.podAnnotations` - Prometheus will determine which pods to scrape metrics from based on pod annotations. eg:

    ```
    podAnnotations: {
      "prometheus.io/path": '/metrics',
      "prometheus.io/port": '9010',
      "prometheus.io/scrape": 'true'
    }
    ```

* `hpa` - A Horizontal Pod Autoscaler (HPA) will be used to scale the replica count of the Executors. eg:

    ```
    hpa:
    # Maximum number of replicas
    maxReplicas: 10
    # Minimum number of replicas
    minReplicas: 1
    metric:
      # This will be the name of a metric that is available via Prometheus.
      # Please note that fragments_active is just an example of a metric to use.
      # You can use any metrics that are available to Prometheus.
      metricName: fragments_active
      target:
        # Scale up target type
        type: Value
        # Scale up value
        value: 1
    ```

* `podMonitor` - A PodMonitor will be needed to expose metrics from pods to Prometheus. eg:

    ```
    podMonitor:
      # The podMetricsEndpoints will be queried by Prometheus to extract metrics
      podMetricsEndpoints:
        - path: /metrics
          interval: 10s
          port: prometheus
    ```
