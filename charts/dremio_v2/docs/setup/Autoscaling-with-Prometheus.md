# Autoscaling Dremio Executors Based on Prometheus Metrics
The number of Dremio Executors can be autoscaled based on metrics that are exposed by Prometheus.

### Graceful Shutdown
To prevent Kubernetes from deleting pods that are currently executing queries, we will use `postStart` and `preStop` hooks in the Helm chart to add/remove executor nodes from the denied nodes list via the [Dremio API](https://docs.dremio.com/software/rest-api/nodeCollections/).

### Prerequisites
* [Prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus) and [Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter) must be installed in the Kubernetes cluster

* A Dremio User with admin privileges must be created to interact with the Dremio API for [graceful shutdown](#graceful-shutdown). **NOTE:** Since graceful shutdown requires Dremio Admin credentials, auto scaling **cannot** be configured until after Dremio has been initialized and a Dremio User with admin privileges has been created

* A custom Docker image must be used. Using the Docker file in the autoscale-handler directory, build a Docker image and push it to a repository. Then in `values.yaml`, update the `image` and `imageTag` to match this custom image

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

* `secrets` - As a part of [graceful shutdown](#graceful-shutdown), Dremio User credentials will be needed. In addition to credentials, we will also need the Dremio Endpoint URL. eg:

    ```
    secrets:
      DREMIO_USER: test_user
      DREMIO_PASSWORD: test_password
      DREMIO_URL: http://base_url:9047
    ```

* `hpa` - A Horizontal Pod Autoscaler (HPA) will be used to scale the replica count of the Executors. eg:

    ```
    hpa:
    # Maximum number of replicas
    maxReplicas: 10
    # Minimum number of replicas
    minReplicas: 1
    metric:
      # This will be the name of a metric that is available via Prometheus
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
    # The PodMonitor will expose metrics to Prometheus for based on matchLabels.
    # To target the dremio-executors, use 'role: dremio-cluster-pod'
      matchLabels:
        role: dremio-cluster-pod
      # The podMetricsEndpoints will be queried by Prometheus to extract metrics
      podMetricsEndpoints:
        - path: /metrics
          interval: 10s
          port: prometheus
    ```

* `additionalConfigMap` - An additional config map will be used to store Prometheus configuration values. eg:

    ```
    additionalConfigMap:
      PROMETHEUS_ENDPOINT: http://prometheus_endpoint
      PROMETHEUS_PORT: "9010"
      PROMETHEUS_WAIT_TIME: "4"
      PROMETHEUS_QUERY_MAX_RETRIES: "1000"
    ```

* `executor.lifecycle` - `postStop` and `preStop` hooks are required for [graceful shutdown](#graceful-shutdown). eg:

    ```
    lifecycle:
      postStart:
        exec:
          command: ["bash", "/opt/dremio/bin/autoscale-handler.sh", "-a", "remove"]
      preStop:
        exec:
          command: ["bash", "/opt/dremio/bin/autoscale-handler.sh", "-a", "add"]
    ```