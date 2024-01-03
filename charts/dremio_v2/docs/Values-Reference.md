# `Values.yaml` Reference

🔎 To search this document for specific values, use dot-notation to search, i.e. `coordinator.volumeSize`.

ℹ️ In all code examples, `[...]` denotes additional values that have been omitted.

## Top Level Values

### Image Configuration

#### `image`

Type: String

By default, the image is set to `dremio/dremio-oss`, the community edition of Dremio.

The `image` refers to the location to retrieve the specific container image for Dremio. In some cases, the `image` value may vary in corporate environments where there may be a private container registry that is used.

#### `imageTag`

Type: String

By default, the value is set to `latest`.

The `imageTag` refers to the tag/version of the container image for Dremio.

***Note***: It is **strongly** recommended to pin the version of Dremio that we are deploying by setting the `imageTag` to a precise version and not leave the value as latest. If you are directly consuming Dremio's images from Docker Hub, when specifying which version to use, it is recommended to use the full version tag in the form `X.Y.Z` (i.e. `21.1.0`), as image tags in the form `X.Y` (i.e. `21.1`) are continually updated with the latest patch version released. Since Dremio versions are not backwards compatible, leaving it as latest or in the form `X.Y` may automatically upgrade Dremio during pod creation.

#### `imagePullSecrets`

Type: Array

By default, this value is not set.

In some environments, an internal mirror may be used that requires authentication. For enterprise users, you may need to specify the `imagePullSecret` for the Kubernetes cluster to have access to the Dremio enterprise image. Please refer to the documentation [Pull an Image from a Private Repository](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) provided by Kubernetes on how to create an image pull secret.


### Kubernetes Service Account

#### `serviceAccount`

Type: String

By default, this value is not set and will use the default service account configured for the Kubernetes cluster.

This value can be independently overridden in each section ([`coordinator`](#coordinator), [`executor`](#executor), [`zookeeper`](#zookeeper)).

More Info: See the [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) documentation for Kubernetes.

### Storage Configuration

#### `storageClass`

Type: String

By default, this value is not set and will use the default storage class configured for the Kubernetes cluster.

Storage class has a direct impact on the performance of the Dremio cluster. Optionally set this value to use the same storage class for all persistent volumes created. This value can be independently overridden in each section ([`coordinator`](#coordinator), [`executor`](#executor), [`zookeeper`](#zookeeper)).

More Info: See the [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) documentation for Kubernetes.

### Annotations, Labels, Node Selectors, Tags, and Tolerations

By default, these values are set to empty. These values can be independently overridden in each section ([`coordinator`](#coordinator), [`executor`](#executor), [`zookeeper`](#zookeeper)).

#### `annotations`

Type: Dictionary

The annotations set at this root level are used by all `StatefulSet` resources unless overridden in their respective configuration sections.

For example, you can set annotations as follows:

```yaml
annotations:
  example-annotation-one: "example-value-one"
  example-annotation-two: "example-value-two"
[...]
```

More Info: See the [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) documentation for Kubernetes.

#### `podAnnotations`

Type: Dictionary

The pod annotations set at this root level are used by all `Pod` resources unless overridden in their respective configuration sections.

For example, you can set pod annotations as follows:

```yaml
podAnnotations:
  example-pod-annotation-one: "example-value-one"
  example-pod-annotation-two: "example-value-two"
[...]
```

More Info: See the [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) documentation for Kubernetes.

#### `labels`

Type: Dictionary

The labels set at this root level are used by all `StatefulSet` resources unless overridden in their respective configuration sections.

For example, you can set labels as follows:

```yaml
labels:
  example-label-one: "example-value-one"
  example-label-two: "example-value-two"
[...]
```

More Info: See the [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) documentation for Kubernetes.

#### `podLabels`

Type: Dictionary

The pod labels set at this root level are inherited by all `Pod` resources unless overridden in their respective configuration sections.

For example, you can set pod labels as follows:

```yaml
podLabels:
  example-pod-label-one: "example-value-one"
  example-pod-label-two: "example-value-two"
[...]
```

More Info: See the [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) documentation for Kubernetes.

#### `nodeSelector`

Type: Dictionary

The node selectors set at this root level are inherited by all `Pod` resources unless overridden in their respective configuration sections.

For example, you can set the node selector to select nodes that have a label `diskType` of value `ssd` as follows:

```yaml
nodeSelector:
  diskType: "ssd"
[...]
```

More Info: See the [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) section of Assigning Pods to Nodes documentation for Kubernetes.

#### `tolerations`

Type: Array

The tolerations set at this root level are inherited by all `Pod` resources unless overridden in their respective configuration sections.

For example, if there is a node with the taint `example-key=example-value:NoSchedule`, you can set the tolerations to allow the pod to be scheduled as follows:

```yaml
tolerations:
- key: "example-key"
  operator: "Exists"
  effect: "NoSchedule"
[...]
```

More Info: See the [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) documentation for Kubernetes.

### Dremio Configuration

#### `coordinator`

Type: Dictionary

This section controls the deployment of coordinator instance(s). See the [Coordinator Values](#coordinator-values) section.

#### `executor`

Type: Dictionary

This section controls the deployment of executor instance(s). See the [Executor Values](#executor-values) section.

#### `distStorage`

Type: Dictionary

This section controls Dremio's distributed storage configuration. See the [Distributed Storage Values](#distributed-storage-values) section.

#### `service`

Type: Dictionary

This section controls Dremio's Kubernetes service which is exposed to end users of Dremio. See the [Service Values](#storage-values) section.

### Zookeeper Configuration

#### `zookeeper`

Type: Dictionary

This section controls the deployment of Zookeeper in Kubernetes. See the [Zookeeper Values](#zookeeper-values) section.

### Advanced Configuration

#### `extraStartParams`

Type: String

By default, this value is not set.

This value controls additional parameters passed to the Dremio process.

For example, to pass an additional system property to the java process, you can specify the following:

```yaml
extraStartParams: >-
  -DsomeTestKey=someValue
[...]
```

#### `extraInitContainers`

Type: String

By default, this value is not set.

This value controls additional `initContainers` that are started as part of the initialization process for Dremio's pods. The value specified here may reference values specified in the built-in `Values` object in Helm.

For example, to have an `initContainer` with the Dremio image, you can specify the following:

```yaml
extraInitContainers: |
  - name: dremio-hello-world
    image: {{ $.Values.image }}:{{ $.Values.imageTag }}
    command: ["echo", "Hello World"]
[...]
```

#### `extraVolumes`

Type: Array

By default, this value is not set.

This value controls additional volumes that are attached to the Dremio's pods. This specifies additional volumes that should be mountable to the containers in Dremio's pods. This value is typically used in conjunction with `extraVolumeMounts`.

For example, if you have a `ConfigMap` named  `cm-dremio-additional-files` with additional files that you want to include in the running Dremio pods, you can specify the following:

```yaml
extraVolumes:
- name: dremio-additional-files
  configMap:
    name: cm-dremio-additional-files
[...]
```

#### `extraVolumeMounts`

Type: Array

By default, this value is not set.

This value controls the additional volumes that should be mounted to the Dremio containers and the paths that each volume should be mounted at. This value is typically used in conjunction with `extraVolumes`.

For example, if you have set the above `extraVolumes` value as shown in the example, you can map this volume into the path `/additional-files` as follows:

```yaml
extraVolumeMounts:
- name: dremio-additional-files
  mountPath: "/additional-files"
[...]
```

## Coordinator Values

### General Configuration

#### `coordinator.cpu` & `coordinator.memory`

Type: Integer

By default, the value of `cpu` is `15` and the value of memory is `122800` (MB).

The values for `cpu` and `memory` control the amount of CPU and memory in MB being requested for each coordinator instance for the purposes of scheduling a coordinator to a specific node in the Kubernetes cluster.

***Note***: While the values specified are not upper bounds, the value of `memory` specified here is used by the chart to calculate the allocation of heap and direct memory used by Dremio.

#### `coordinator.count`

Type: Integer

By default, the value is set to `0`.

Increasing this number controls the *secondary* coordinators that are launched as part of the deployment. Regardless of this value, at minimum one master coordinator is launched as part of the deployment. The total number of coordinator instances launched will always be `coordinator.count + 1`.

#### `coordinator.volumeSize`

Type: String

By default, the value is set to `512Gi`.

The coordinator volume is used to store the RocksDB KV store and requires a performant disk. In most hosted Kubernetes environments, disk performance is determined by the size of the volume.

### Web UI

#### `coordinator.web.port`

Type: Integer

By default, the value is set to `9047`.

To change the port that Dremio listens on, change the port to a desired value. The valid range of ports is 1 to 65535.

#### `coordinator.web.tls.enabled`

Type: Boolean

By default, the value is set to `false`.

To enable TLS on the web UI, set this value to `true`. Also, provide a value for `coordinator.web.tls.secret` that corresponds with the TLS secret that should be used.

#### `coordinator.web.tls.secret`

Type: String

By default, the value is set to `dremio-tls-secret-ui`.

This value is ignored if `coordinator.web.tls.enabled` is not set to `true`. This value should reference the TLS secret object in Kubernetes that contains the certificate for the client JDBC/ODBC connections.

For example, to have TLS enabled for the web UI using a certificate created called `dremio-tls-secret-ui`, you can set the configuration as follows:

```yaml
coordinator:
  [...]
  web:
    tls:
      enabled: true
      secret: dremio-tls-secret-ui
[...]
```

To create a secret, use the following command: `kubectl create secret tls ${TLS_SECRET_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}` providing appropriate values for `TLS_SECRET_NAME`, `KEY_FILE`, `CERT_FILE`.

***Note***: Dremio does not support auto-rotation of secrets. To update the secret used by Dremio, restart the coordinator pods to have the new TLS secret take effect.

More Info: See the [Creating your own Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets) section of the Secrets documentation for Kubernetes.

#### `coordinator.startupProbe.failureThreshold`

Type: Integer

By default, the value is set to `300`.

This value controls the maximum failures allowed before the pod is restarted.

Max timeout for the startupProbe is calculated as `coordinator.startupProbe.failureThreshold` * `coordinator.startupProbe.periodSeconds`

#### `coordinator.startupProbe.periodSeconds`

Type: Integer

By default, the value is set to `1`.

This value controls the probe polling frequency expressed in seconds.

#### `coordinator.readinessProbe.failureThreshold`

Type: Integer

By default, the value is set to `120`.

This value controls the maximum failures allowed before the pod is restarted.

Max timeout for the startupProbe is calculated as `coordinator.readinessProbe.failureThreshold` * `coordinator.readinessProbe.periodSeconds`

#### `coordinator.readinessProbe.periodSeconds`

Type: Integer

By default, the value is set to `1`. This value controls the probe polling frequency expressed in seconds.

### Client (JDBC/ODBC)

#### `coordinator.client.tls.enabled`

Type: Boolean

By default, the value is set to `false`. This is an **enterprise only feature** and should not be set to true when using a community edition of Dremio.

To enable TLS on the client ODBC/JDBC port, set this value to `true`. Also, provide a value for `coordinator.client.tls.secret` that corresponds with the TLS secret that should be used.

#### `coordinator.client.tls.secret`

Type: String

By default, the value is set to `dremio-tls-secret-client`.

This value is ignored if `coordinator.client.tls.enabled` is not set to `true`. This value should reference the TLS secret object in Kubernetes that contains the certificate for the client JDBC/ODBC connections.

For example, to have TLS enabled for the client JDBC/ODBC connections using a certificate created called `dremio-tls-secret-client`, you can set the configuration as follows:

```yaml
coordinator:
  [...]
  client:
    tls:
      enabled: true
      secret: dremio-tls-secret-client
[...]
```

To create a secret, use the following command: `kubectl create secret tls ${TLS_SECRET_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}` providing appropriate values for `TLS_SECRET_NAME`, `KEY_FILE`, `CERT_FILE`.

***Note***: Dremio does not support auto-rotation of secrets. To update the secret used by Dremio, restart the coordinator pods to have the new TLS secret take effect.

More Info: See the [Creating your own Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets) section of the Secrets documentation for Kubernetes.

### Flight

#### `coordinator.flight.tls.enabled`

Type: Boolean

By default, the value is set to `false`.

To enable TLS on the Flight port, set this value to `true`. Also, provide a value for `coordinator.flight.tls.secret` that corresponds with the TLS secret that should be used.

#### `coordinator.flight.tls.secret`

Type: String

By default, the value is set to `dremio-tls-secret-flight`.

This value is ignored if `coordinator.flight.tls.enabled` is not set to `true`. This value should reference the TLS secret object in Kubernetes that contains the certificate for the Flight connections.

For example, to have TLS enabled for the Flight connections using a certificate created called `dremio-tls-secret-flight`, you can set the configuration as follows:

```yaml
coordinator:
  [...]
  flight:
    tls:
      enabled: true
      secret: dremio-tls-secret-flight
[...]
```

To create a secret, use the following command: `kubectl create secret tls ${TLS_SECRET_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}` providing appropriate values for `TLS_SECRET_NAME`, `KEY_FILE`, `CERT_FILE`.

***Note***: Dremio does not support auto-rotation of secrets. To update the secret used by Dremio, restart the coordinator pods to have the new TLS secret take effect.

More Info: See the [Creating your own Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#creating-your-own-secrets) section of the Secrets documentation for Kubernetes.

### Annotations, Labels, Node Selectors, Tags, and Tolerations

By default, these values are not set. If the value is omitted or set to an empty array/dictionary, this value will be inherited from the top level equivalent. For more information about these configuration values, please refer to the top level equivalents of these values.

#### `coordinator.annotations`

Type: Dictionary

The annotations set are used by all coordinator `StatefulSet` resources.

For example, you can set annotations as follows:

```yaml
coordinator:
  [...]
  annotations:
    example-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`annotations`](#annotations) section of this reference.

#### `coordinator.podAnnotations`

Type: Dictionary

The pod annotations set are used by all `Pod`(s) created by the coordinator `StatefulSet`(s).

For example, you can set pod annotations as follows:

```yaml
coordinator:
  [...]
  podAnnotations:
    example-pod-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`podAnnotations`](#podannotations) section of this reference.

#### `coordinator.labels`

Type: Dictionary

The labels set are used by all coordinator `StatefulSet` resources.

For example, you can set labels as follows:

```yaml
coordinator:
  [...]
  labels:
    example-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`labels`](#labels) section of this reference.

#### `coordinator.podLabels`

Type: Dictionary

The pod labels set are used by all  `Pod`(s) created by the coordinator `StatefulSet`(s).

For example, you can set pod labels as follows:

```yaml
coordinator:
  [...]
  podLabels:
    example-pod-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`podLabels`](#podlabels) section of this reference.

#### `coordinator.nodeSelector`

Type: Array

The node selectors set are used by all `Pod`(s) created by the coordinator `StatefulSet`(s).

For example, you can set node selectors as follows:

```yaml
coordinator:
  [...]
  nodeSelector:
    diskType: "ssd"
[...]
```

More Info: Refer to the [`nodeSelector`](#nodeselector) section of this reference.

### Advanced Customizations

#### `coordinator.storageClass`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `storageClass`.

Storage class has a direct impact on the performance of the Dremio cluster. On the master coordinator node, RocksDB is stored on the persistent volume created with this storage class.

More Info: Refer to the [`storageClass`](#storageclass) section of this reference.

#### `coordinator.serviceAccount`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `serviceAccount`.

This service account will also be used by the Dremio admin pod.

More Info: Refer to the [`serviceAccount`](#serviceaccount) section of this reference.

#### `coordinator.extraStartParams`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `extraStartParams`.

This value controls additional parameters passed to the Dremio process.

For example, to pass an additional system property to the java process, you can specify the following:

```yaml
coordinator:
  [...]
  extraStartParams: >-
    -DsomeTestKey=someValue
[...]
```

More Info: Refer to the [`extraStartParams`](#extrastartparams) section of this reference.

#### `coordinator.extraInitContainers`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `extraInitContainers`.

This value controls additional `initContainers` that are started as part of the initialization process for Dremio's coordinator pods. The value specified here may reference values specified in the `values.yaml` file.

For example, to have an `initContainer` with the Dremio image, you can specify the following:

```yaml
coordinator:
  [...]
  extraInitContainers: |
    - name: dremio-hello-world
      image: {{ $.Values.image }}:{{ $.Values.imageTag }}
      command: ["echo", "Hello World"]
[...]
```

More Info: Refer to the [`extraInitContainers`](#extrainitcontainers) section of this reference.

#### `coordinator.extraVolumes`

Type: Array

By default, this value is not set. If this value is omitted or set to an empty array, this value will be inherited from the top level `extraVolumes`.

This value controls additional volumes that are attached to the Dremio coordinator pod. This specifies additional volumes that should be mountable to the containers in the Dremio coordinator pod. This value is typically used in conjunction with `coordinator.extraVolumeMounts`.

For example, if you have a `ConfigMap` named  `cm-dremio-additional-files` with additional files that you want to include in the running Dremio coordinator pods, you can specify the following:

```yaml
coordinator:
  [...]
  extraVolumes:
  - name: dremio-additional-files
    configMap:
      name: cm-dremio-additional-files
[...]
```

More Info: Refer to the [`extraVolumes`](#extravolumes) section of this reference.

#### `coordinator.extraVolumeMounts`

Type: Array

By default, this value is not set. If this value is omitted or set to an empty array, this value will be inherited from the top level `extraVolumeMounts`.

This value controls the additional volumes that should be mounted to the Dremio coordinator container and the paths that the volume should be mounted at. This value is typically used in conjunction with `coordinator.extraVolumes`.

For example, if you have set the above `coordinator.extraVolumes` value as shown in the example, you can map this volume into the path `/additional-files` as follows:

```yaml
coordinator:
  [...]
  extraVolumeMounts:
  - name: dremio-additional-files
    mountPath: "/additional-files"
[...]
```

More Info: Refer to the [`extraVolumeMounts`](#extravolumemounts) section of this reference.

## Executor Values

### General Configuration

#### `executor.cpu` & `executor.memory`

Type: Integer

By default, the value of `cpu` is `15` and the value of memory is `122800` (MB). This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

The values for `cpu` and `memory` control the amount of CPU and memory in MB being requested for each executor instance for the purposes of scheduling an executor to a specific node in the Kubernetes cluster.

***Note***: While the values specified are not upper bounds, the value of `memory` specified here is used by the chart to calculate the allocation of heap and direct memory used by Dremio.

#### `executor.engines`

Type: Array

By default, the value is `["default"]`.

By adding additional values to this list, additional sets of executors are launched. By default, each set of executors will start with `executor.count` number of pods. See the Per-Engine Overrides section of this reference to customize the number of executors are started.

#### `executor.count`

Type: Integer

By default, the value is set to `3`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

Increasing this number controls the number of executors that are launched as part of the engine. Without per-engine overrides, the total number of executor pods started is calculated as the `length(executor.engines) * executor.count`.

#### `executor.volumeSize`

Type: String

By default, the value is set to `128Gi`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

The executor volume is used to store results of queries run. If the `distStore.type` is set to `local`, additional resources such as accelerations may be stored in the volume. In most hosted Kubernetes environments, disk performance is determined by the size of the volume.

### Columnar Cloud Cache (C3) Configuration

#### `executor.cloudCache.enabled`

Type: Boolean

By default, the value is set to `true`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

Columnar cloud cache (C3) is enabled by default on executors. To turn off cloud cache, set this value to `false`.

#### `executor.cloudCache.storageClass`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from `executor.storageClass` or its parent value `storageClass`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

C3 is designed for usage with local NVMe storage devices. If available, it is recommended to setup a [local storage provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/docs/getting-started.md) to allow Dremio to utilize local NVMe storage on the Kubernetes nodes.

#### `executor.cloudCache.volumes`

Type: Array

By default, the value is set to `[{size: 100Gi}]`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

By specifying more than one item in the list, additional volumes are provisioned for C3. Each volume must specify a `size` and optionally a  `name` and custom  `storageClass`. If the volume omits the `storageClass`, the value of `executor.cloudCache.storageClass` or its parent values are used.

For example, if the Kubernetes nodes that are provisioned have three local NVMe storage devices available, then we can create three C3 cache volumes each using a different `size` and combination of custom `name` and `storageClass` values:

```yaml
executor:
  [...]
  cloudCache:
    volumes:
    - size: 300Gi
    - name: "executor-c3-0"
      size: 100Gi
      storageClass: "local-nvme"
    - size: 50Gi
      storageClass: "local-nvme"
[...]
```

### Annotations, Labels, Node Selectors, Tags, and Tolerations

By default, these values are not set. If the value is omitted or set to an empty array/dictionary, this value will be inherited from the top level equivalent. For more information about these configuration values, please refer to the top level equivalents of these values.

#### `executor.annotations`

Type: Dictionary

The annotations set are used by all executor `StatefulSet` resources. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

For example, you can set annotations as follows:

```yaml
executor:
  [...]
  annotations:
    example-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`annotations`](#annotations) section of this reference.

#### `executor.podAnnotations`

Type: Dictionary

The pod annotations set are used by all `Pod`(s) created by the executor `StatefulSet`(s). This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

For example, you can set pod annotations as follows:

```yaml
executor:
  [...]
  podAnnotations:
    example-pod-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`podAnnotations`](#podannotations) section of this reference.

#### `executor.labels`

Type: Dictionary

The labels set are used by all executor `StatefulSet` resources. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

For example, you can set labels as follows:

```yaml
executor:
  [...]
  labels:
    example-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`labels`](#labels) section of this reference.

#### `executor.podLabels`

Type: Dictionary

The pod labels set are used by all  `Pod`(s) created by the executor `StatefulSet`(s). This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

For example, you can set pod labels as follows:

```yaml
executor:
  [...]
  podLabels:
    example-pod-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`podLabels`](#podlabels) section of this reference.

#### `executor.nodeSelector`

Type: Array

The node selectors set are used by all `Pod`(s) created by the executor `StatefulSet`(s). This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

For example, you can set node selectors as follows:

```yaml
executor:
  [...]
  nodeSelector:
    diskType: "ssd"
[...]
```

More Info: Refer to the [`nodeSelector`](#nodeselector) section of this reference.

### Advanced Customizations

#### `executor.storageClass`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `storageClass`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

More Info: Refer to the [`storageClass`](#storageclass) section of this reference.

#### `executor.serviceAccount`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `serviceAccount`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

More Info: Refer to the [`serviceAccount`](#serviceaccount) section of this reference.

#### `executor.extraStartParams`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `extraStartParams`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

This value controls additional parameters passed to the Dremio process.

For example, to pass an additional system property to the java process, you can specify the following:

```yaml
coordinator:
  [...]
  extraStartParams: >-
    -DsomeTestKey=someValue
[...]
```

More Info: Refer to the [`extraStartParams`](#extrastartparams) section of this reference.

#### `executor.extraInitContainers`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `extraInitContainers`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

This value controls additional `initContainers` that are started as part of the initialization process for Dremio's executor pods. The value specified here may reference values specified in the `values.yaml` file.

For example, to have an `initContainer` with the Dremio image, you can specify the following:

```yaml
coordinator:
  [...]
  extraInitContainers: |
    - name: dremio-hello-world
      image: {{ $.Values.image }}:{{ $.Values.imageTag }}
      command: ["echo", "Hello World"]
[...]
```

More Info: Refer to the [`extraInitContainers`](#extrainitcontainers) section of this reference.

#### `executor.extraVolumes`

Type: Array

By default, this value is not set. If this value is omitted or set to an empty array, this value will be inherited from the top level `extraVolumes`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

This value controls additional volumes that are attached to the Dremio executor pod. This specifies additional volumes that should be mountable to the containers in the Dremio executor pod. This value is typically used in conjunction with `executor.extraVolumeMounts`.

For example, if you have a `ConfigMap` named  `cm-dremio-additional-files` with additional files that you want to include in the running Dremio executor pods, you can specify the following:

```yaml
executor:
  [...]
  extraVolumes:
  - name: dremio-additional-files
    configMap:
      name: cm-dremio-additional-files
[...]
```

More Info: Refer to the [`extraVolumes`](#extravolumes) section of this reference.

#### `executor.extraVolumeMounts`

Type: Array

By default, this value is not set. If this value is omitted or set to an empty array, this value will be inherited from the top level `extraVolumeMounts`. This value can be set on a **per-engine basis**, see the [Per-Engine Configuration](#per-engine-configuration) section.

This value controls the additional volumes that should be mounted to the Dremio executor container and the paths that the volume should be mounted at. This value is typically used in conjunction with `executor.extraVolumes`.

For example, if you have set the above `executor.extraVolumes` value as shown in the example, you can map this volume into the path `/additional-files` as follows:

```yaml
executor:
  [...]
  extraVolumeMounts:
  - name: dremio-additional-files
    mountPath: "/additional-files"
[...]
```

More Info: Refer to the [`extraVolumeMounts`](#extravolumemounts) section of this reference.

#### `executor.nodeLifecycleService`
Type: Dictionary


**Prerequisite**: To use this feature, [Prometheus Adapter](https://github.com/kubernetes-sigs/prometheus-adapter) must be installed in your cluster.

To enable this service with minimum configuration and all default values, set `executor.nodeLifeCycleService` to:

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

Here's an example of a full configuration:
```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    maxEngines: 10
    metricsPort: 9010
    terminationGracePeriodSeconds: 60
    scalingMetrics:
      default:
        enabled: true
        cpuAverageUtilization: 50
        memoryAverageUtilization: 50
      userDefinedMetrics:
        - pods:
          metric:
            name: threads_waiting_count
          target:
            averageValue: "20"
            type: AverageValue
          type: Pods
    scalingBehavior:
      scaleDown:
        defaultPolicy:
          enabled: true
          value: 1
          periodSeconds: 30
        userDefinedPolicies:
          - type: Pods
            value: 2
            periodSeconds: 10
      scaleUp:
        defaultPolicy:
          enabled: true
          value: 900
          periodSeconds: 60
        userDefinedPolicies:
          - type: Percent
            value: 30
            periodSeconds: 30
  [...]
```

`executor.nodeLifecycleService.enabled`

Type: Boolean

To enable dynamic scaling, this key must be present and set to `true`.

`executor.nodeLifecycleService.metricsPort`
Type: Integer

By default, this value is set to 9010. This is the port where the `/metrics` endpoint is available for a pod.

`executor.nodeLifecycleService.terminationGracePeriodSeconds`

Type: Integer

By default, this value is set to `600`. The Dremio process will wait this period to allow for running work to complete. After this,
time has passed, any running work will be canceled.

`executor.nodeLifecycleService.maxEngines`

Type: Integer

By default, this value is set to `50`

`executor.nodeLifecycleService.scalingMetrics`

Type: Dictionary

The calculation of the desired number of engines is based on scaling metrics and a target value for this metric.

`executor.nodeLifecycleService.scalingMetrics.default`

Type: Boolean

By default, default scaling metrics are enabled. The default metrics are based on CPU and Memory average utilization.

`executor.nodeLifecycleService.scalingMetrics.cpuAverageUtilization`

By default, this value is omitted. If left omitted, this value will default to `70`. To configure this value, this key must be present. Example:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    scalingMetrics:
      default:
        enabled: true
        cpuAverageUtilization: 50
  [...]
```
`executor.nodeLifecycleService.scalingMetrics.memoryAverageUtilization`

By default this value is omitted. If left omitted, this value will default to `70`. To configure this value, this key must be present. Example:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    scalingMetrics:
      default:
        enabled: true
        memoryAverageUtilization: 50
  [...]
```

`executor.nodeLifecycleService.scalingMetrics.userDefinedMetrics`

Type: Array

By default, this value is omitted. Below is an example of adding a user defined scaling metric:


```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    scalingMetrics:
      default:
        enabled: true
      userDefinedMetrics:
        - pods:
            metric:
              name: threads_waiting_count
            target:
              averageValue: "10"
              type: AverageValue
          type: Pods
  [...]
```
`executor.nodeLifecycleService.scalingBehavior.scaleDown.stabilizationWindowSeconds`

Type: Int

By default, this is set to `300` seconds. This value indicates the amount of time the HPA controller should consider
previous recommendations to prevent flapping of the number of replicas

`executor.nodeLifecycleService.scalingBehavior.scaleDown.defaultPolicy.enabled`

Type: Boolean

By default, default scale down behavior is enabled. The default behavior is scale down 1 engine every 10 minutes.

`executor.nodeLifecycleService.scalingBehavior.scaleDown.defaultPolicy.value`

Type: Integer

By default, this is set to scale down `1` engine at a time. Example of configuring this value:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    [...]
    scalingBehavior:
      scaleDown:
        defaultPolicy:
          enabled: true
          value: 3
    [...]
  [...]
```

`executor.nodeLifecycleService.scalingBehavior.scaleDown.defaultPolicy.value`
Type: Integer

By default, this value is set trigger a scale down event every `600` seconds. Example of configuring this value:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    [...]
    scalingBehavior:
      scaleDown:
        defaultPolicy:
          enabled: true
          periodSeconds: 30
    [...]
  [...]
```


`executor.nodeLifecycleService.scalingBehavior.scaleDown.userDefinedPolicies`

Type: Array

By default, this value is omitted. Example of adding user defined scale down policies:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    [...]
    scalingBehavior:
      scaleDown:
        userDefined:
          - type: Pods
            value: 2
            periodSeconds: 10
    [...]
  [...]
```

`executor.nodeLifecycleService.scalingBehavior.scaleUp.stabilizationWindowSeconds`

Type: Int

By default, this is set to `300` seconds. This value indicates the amount of time the HPA controller should consider
previous recommendations to prevent flapping of the number of replicas

`executor.nodeLifecycleService.scalingBehavior.scaleUp.defaultPolicy.enabled`

Type: Boolean

The default scale up policy designed to respond to a traffic increase quickly. This is the default scale up policy:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    [...]
    scalingBehavior:
      scaleUp:
        defaultPolicy:
          - type: Percent
            value: 900
            periodSeconds: 60
    [...]
  [...]
```

The 900 implies that 9 times the current number of pods can be added, effectively making the number of replicas 10
times the current size. If the application is started with 1 pod, it will scale up with the following number of pods:

`1 -> 10 -> 100 -> 1000`

`executor.nodeLifecycleService.scalingBehavior.scaleUp.defaultPolicy.value`

Type: Integer

By default, this value is set to `900`. See `executor.nodeLifecycleService.scalingBehavior.scaleUp.defaultPolicy.enabled`
for more information.

`executor.nodeLifecycleService.scalingBehavior.scaleUp.defaultPolicy.periodSeconds`

By default, this value is set to `60`. See `executor.nodeLifecycleService.scalingBehavior.scaleUp.defaultPolicy.enabled`
for more information.

`executor.nodeLifecycleService.scalingBehavior.scaleUp.userDefinedPolicies`

Type: Array

By default, this value is omitted. Example of adding user defined scale up policies:

```yaml
executor:
  [...]
  nodeLifecycleService:
    enabled: true
    [...]
    scalingBehavior:
      scaleUp:
        userDefined:
          - type: Percent
            value: 100
            periodSeconds: 60
    [...]
  [...]
```

### Per-Engine Configuration

#### `executor.engineOverride.<engine-name>`

Type: Dictionary

By default, this value is not set.

Engine overrides use the name of the engine provided in the `executor.engines` array to allow customization on a per-engine basis. The value of `<engine-name>` should be the name of an engine provided in `executor.engines`.

For example, the following shows all the supported override values being set (which override the shared values from `executor`):

```yaml
executor:
  [...]
  engineOverride:
    <engine-name>:
      cpu: 4
      memory: 144800

      count: 2

      annotations:
        example-annotation-one: "example-value-one"
        example-annotation-two: "example-value-two"
      podAnnotations:
        example-pod-annotation-one: "example-value-one"
        example-pod-annotation-two: "example-value-two"
      labels:
        example-label-one: "example-value-one"
        example-label-two: "example-value-two"
      podLabels:
        example-pod-label-one: "example-value-one"
        example-pod-label-two: "example-value-two"
      nodeSelector:
        diskType: "ssd"
      tolerations:
      - key: "example-key"
        operator: "Exists"
        effect: "NoSchedule"

      serviceAccount: "internal"

      extraStartParams: >-
        -DsomeTestKey=someValue

      extraInitContainers: |
        - name: dremio-hello-world
          image: {{ $.Values.image }}:{{ $.Values.imageTag }}
          command: ["echo", "Hello World"]

      extraVolumes:
      - name: dremio-additional-files
        configMap:
          name: cm-dremio-additional-files

      extraVolumeMounts:
      - name: dremio-additional-files
        mountPath: "/additional-files"

      volumeSize: 50Gi
      storageClass: "managed-premium"

      cloudCache:
        enabled: true

        storageClass: "local-nvme"

        volume:
        - size: 300Gi
        - name: "executor-c3-0"
          size: 100Gi
          storageClass: "local-nvme"
        - size: 50Gi
          storageClass: "local-nvme"
          
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

#### `executor.engineOverride.<engine-name>.volumeClaimName`

Type: String

By default, this value is not set.

When set, this will be the volume claim name used for the persistent volume by an engine. Unless moving from an old Helm chart with existing volume claims that must be retained, this value should not be used. This value should only be used for the `default` engine as persistent volume claims are pod name dependent as well and non-`default` engines will not match the pod name required.

For example, if moving from an old Helm chart that used `dremio-executor-volume`, you can continue to use the volumes for the `default` engine by specifying the following:

```yaml
executor:
  [...]
  engineOverride:
    default:
      volumeClaimName: dremio-executor-volume
[...]
```

## Distributed Storage Values

### General Configuration

#### `distStorage.type`

Type: String

By default, this value is set to `local`.

***Note***: 'local' has been deprecated in Dremio 21.0.0+.

The valid values for `distStorage.type` are `local` (not recommended, not supported in Dremio 21.0.0+), `aws`, `azure`, `azureStorage` or `gcp`. For specific configuration values for each, see the associated sections:

* `aws` (S3): [AWS S3](#aws-s3)
* `azure` (Azure ADLS Gen 1): [Azure ADLS Gen 1](#azure-adls-gen-1)
* `azureStorage` (Azure Storage Gen2): [Azure Storage Gen2](#azure-storage-gen2)
* `gcp` (Google Cloud Storage): [Google Cloud Storage](#google-cloud-storage)

For example, to use AWS S3 as the distributed storage location, you can specify the following:

```yaml
distStorage:
  [...]
  type: "aws"
[...]
```

### AWS S3

#### `distStorage.aws.bucketName`

Type: String

By default, this value is set to `AWS Bucket Name` and must be changed to a valid bucket name.

Specify a valid bucket name that Dremio has write access to. For the required permissions, please see the [Amazon S3](http://docs.dremio.com/deployment/dist-store-config.html#amazon-s3) section of the Configuration Distributed Storage documentation for Dremio.

#### `distStorage.aws.path`

Type: String

By default, this value is set to `/`.

Dremio will write to the root path of the provided bucket. Set this value to an alternative path if you would like Dremio to write its contents to a subdirectory.

#### `distStorage.aws.authentication`

Type: String

The valid values for `distStorage.aws.authentication` are:
* `metadata` (default) - Dremio will attempt to use the instance profile of the EKS node to authenticate to the S3 bucket.
* `accessKeySecret` - The values `distStorage.aws.credentials.accessKey` and `distStorage.aws.credentials.secret` are used to authenticate.
* `awsProfile` - The `distStorage.aws.credentials.awsProfileName` value is used to authenticate.

***Note***: Dremio does not support service account IAM roles on EKS.

#### Credentials for AWS S3

When providing credentials, both `distStorage.aws.credentials.accessKey` and `distStorage.aws.credentials.secret` should be provided.

For example, the following `distStorage` configuration may be used:

```yaml
distStorage:
  [...]
  aws:
    bucketName: "demo.dremio.com"
    path: "/"
    authentication: "accessKeySecret"
    credentials:
      accessKey: "SOME_VALID_KEY"
      secret: "SOME_VALID_SECRET"
[...]
```

##### `distStorage.aws.credentials.accessKey`

Type: String

By default, this value is not set.

For Dremio to authenticate via access key and secret, provide a valid access key value.

##### `distStorage.aws.credentials.secret`

Type: String

By default, this value is not set.

For Dremio to authenticate via access key and secret, provide a valid secret value.

#### AWS Profile Authentication for AWS S3

When using `awsProfile` for `distStorage.aws.authentication`, a folder containing a valid AWS `credentials` file needs to be mounted to `/opt/dremio/aws`.

If using a profile that uses the `credentials_process` option, the target process needs to be mounted to the location specified in the `credentials` file. The script must also be marked as executable. If using a ConfigMap along with the `defaultMode` option, use a decimal value `511` which corresponds to octal `0777`.

##### `distStorage.aws.credentials.awsProfileName`

Type: String

By default, this value is not set.

Specifies the AWS profile name to use for AWS profile authentication.

#### Advanced Configuration for AWS S3

##### `distStorage.aws.extraProperties`

Type: String

By default, this value is not set.

This value can be used to specify additional properties to `core-site.xml` which is used to configure properties for the distributed storage source.

For example, to set the S3 endpoint, you can do the following:

```yaml
distStorage:
  aws:
    [...]
    extraProperties: |
      <property>
        <name>fs.s3a.endpoint</name>
        <value>s3.us-west-2.amazonaws.com</value>
      </property>
[...]
```

### Azure ADLS Gen 1

#### `distStorage.azure.datalakeStoreName`

Type: String

By default, this value is set to `Azure Datalake Store Name` and must be changed to a valid ADLS datalake store name.

Specify a valid datalake store name that Dremio has write access to. For the required permissions, please see the [Azure Configuration](http://docs.dremio.com/data-sources/azure-data-lake-store.html#azure-configuration) section of the Azure Data Lake Storage Gen1 documentation for Dremio.

#### `distStorage.azure.path`

Type: String

By default, this value is set to `/`.

Dremio will write to the root path of the provided datalake store. Set this value to an alternative path if you would like Dremio to write its contents to a subdirectory.

#### Credentials for Azure ADLS Gen 1

##### `distStorage.azure.credentials.applicationId`

Type: String

By default, this value is set to `Azure Application ID` and must be changed to a valid Azure Application ID.

For Dremio to authenticate to the datalake store, provide a valid application ID.

##### `distStorage.azure.credentials.secret`

Type: String

By default, this value is set to `Azure Application Secret` and must be changed to a valid Azure Application Secret.

For Dremio to authenticate to the datalake store, provide a valid secret value.

##### `distStorage.azure.credentials.oauth2Endpoint`

Type: String

By default, this value is set to `Azure OAuth2 Endpoint` and must be changed to a valid Azure OAuth2 endpoint.

For Dremio to authenticate to the datalake store, provide a valid OAuth2 endpoint.

#### Advanced Configuration for Azure ADLS Gen 1

##### `distStorage.azure.extraProperties`

Type: String

By default, this value is not set.

This value can be used to specify additional properties to `core-site.xml` which is used to configure properties for the distributed storage source.

For example, to disable the cache (this value should not be set in production), you can do the following:

```yaml
distStorage:
  aws:
    [...]
    extraProperties: |
      <property>
        <name>fs.adl.impl.disable.cache</name>
        <value>true</value>
      </property>
```

### Azure Storage Gen2

#### `distStorage.azureStorage.accountName`

Type: String

By default, this value is set to `Azure Storage Account Name` and must be changed to a valid Azure Storage account name.

Specify a valid datalake store name that Dremio has write access to. For the required permissions, please see the [Granting Azure Data Lake Store access](https://docs.dremio.com/data-sources/azure-data-lake-store.html#granting-azure-data-lake-store-access) section of the Azure Data Lake Storage Gen1 documentation for Dremio.

#### `distStorage.azureStorage.filesystem`

Type: String

By default, this value is set to `Azure Storage Account Blob Container` and must be changed to a valid Azure Storage blob container.

Specify a valid Azure Storage blob container that Dremio has write access to.

#### `distStorage.azureStorage.path`

Type: String

By default, this value is set to `/`.

Dremio will write to the root path of the provided Azure Storage blob container. Set this value to an alternative path if you would like Dremio to write its contents to a subdirectory.

#### Credentials for Azure Storage Gen2

##### `distStorage.azureStorage.credentials.accessKey`

Type: String

By default, this value is set to `Azure Storage Account Access Key` and must be changed to a valid access key.

For Dremio to authenticate to the provided Azure Storage blob container, provide a valid access key.

#### Advanced Configuration for Azure Storage Gen2

##### `distStorage.azureStorage.extraProperties`

Type: String

By default, this value is not set.

This value can be used to specify additional properties to `core-site.xml` which is used to configure properties for the distributed storage source.

For example, to disable SSL connections (this value should not be set in production), you can do the following:

```yaml
distStorage:
  aws:
    [...]
    extraProperties: |
      <property>
        <name>dremio.azure.secure</name>
        <value>false</value>
      </property>
[...]
```
### Google Cloud Storage

#### `distStorage.gcp.bucketName`

Type: String

By default, this value is set to `GCS Bucket Name` and must be changed to a valid bucket name.

Specify a valid bucket name that Dremio has write access to.

#### `distStorage.gcp.path`

Type: String

By default, this value is set to `/`.

Dremio will write to the root path of the provided bucket. Set this value to an alternative path if you would like Dremio to write its contents to a subdirectory.

#### `distStorage.gcp.authentication`

Type: String

By default, this value is set to `auto`.

The valid values for `distStorage.gcp.authentication` are `auto` or `serviceAccountKeys`. When set to `auto`, Dremio will use Google Application Default Credentials to authenticate to the GCS bucket.

***Note***: On GKE clusters with [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) enabled, we recommend creating a Kubernetes [Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) and setting [`serviceAccount`](#serviceaccount) to reference the Kubernetes service account. If specifying different service accounts for coordinators/executors, ensure that all service accounts have access to the GCS bucket.

#### Credentials for GCP GCS

When set to `serviceAccountKeys`, the values `distStorage.gcp.credentials.projectId`, `distStorage.gcp.credentials.clientId`, `distStorage.gcp.credentials.clientEmail`, `distStorage.gcp.credentials.privateKeyId` and `distStorage.gcp.credentials.privateKey` are used to authenticate to the GCS bucket.

For example, to use service account credential keys, you can do the following:

```yaml
distStorage:
  [...]
  gcp:
    bucketName: "demo-bucket.dremio.com"
    path: "/"
    authentication: "serviceAccountKeys"
    credentials:
      projectId: "dremio-demo-project"
      clientId: "000000000"
      clientEmail: "demo-service-account@dremio-demo-project.iam.gserviceaccount.com"
      privateKeyId: "0000000000000000000000000000000000000000"
      privateKey: |-
        -----BEGIN PRIVATE KEY-----\nPRIVATE KEY\n-----END PRIVATE KEY-----\n
[...]
```

Alternatively, for example, to use a Kubernetes Service Account on GKE with Workload Identity:

```yaml
serviceAccount: "k8s-service-account-name"
distStorage:
  [...]
  gcp:
    bucketName: "demo-bucket.dremio.com"
    path: "/"
    authentication: "auto"
[...]
```

##### `distStorage.gcp.credentials.projectId`

Type: String

By default, this value is not set.

For Dremio to authenticate with service account credential keys, provide the project ID for the service account.

##### `distStorage.gcp.credentials.clientId`

Type: String

By default, this value is not set.

For Dremio to authenticate with service account credential keys, provide the client ID for the service account.

##### `distStorage.gcp.credentials.clientEmail`

Type: String

By default, this value is not set.

For Dremio to authenticate with service account credential keys, provide the client email for the service account.

##### `distStorage.gcp.credentials.privateKeyId`

Type: String

By default, this value is not set.

For Dremio to authenticate with service account credential keys, provide the private key ID for the service account.

##### `distStorage.gcp.credentials.privateKey`

Type: String

By default, this value has a partial snippet of a private key.

For Dremio to authenticate with service account credential keys, provide the private key for the service account. Ensure this value is provided in one line. You can directly copy the value as-is from the credentials JSON file, including any special characters, but without surrounding quotes.

#### Advanced Configuration for GCP GCS

##### `distStorage.gcp.extraProperties`

Type: String

By default, this value is not set.

This value can be used to specify additional properties to `core-site.xml` which is used to configure properties for the distributed storage source.

## Storage Values

### General Configuration

#### `service.type`

Type: String

By default, this value is set to `LoadBalancer`.

In some environments, a `LoadBalancer` may not be available. You may alternatively set the type to `ClusterIP` for cluster-only usage of Dremio or `NodePort` to make the service available via the port on the Kubernetes node.

For example, to make Dremio only accessible in the Kubernetes cluster, you can do the following:

```yaml
service:
  [...]
  type: ClusterIP
[...]
```

#### `service.sessionAffinity`

Type: Boolean

By default, this value is not set, which defaults to `false`.

To enable session affinity, set this value to `ClientIP`. Session affinity is critical for the web UI when there `coordinator.count` is greater than 0.

If utilizing Flight, please see [Important Setup Considerations](https://github.com/dremio/dremio-cloud-tools/blob/master/charts/dremio_v2/docs/setup/Important-Setup-Considerations.md) for more information about enabling session affinity.

### Annotations and Labels

By default, these values are not set. If the value is omitted or set to an empty array/dictionary, this value will be inherited from the top level equivalent. For more information about these configuration values, please refer to the top level equivalents of these values.

#### `service.annotations`

Type: Dictionary

The annotations set are used by the `Service` resource.

For example, you can set annotations as follows:

```yaml
service:
  [...]
  annotations:
    example-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`annotations`](#annotations) section of this reference.

#### `service.labels`

Type: Dictionary

The labels set are used by the `Service` resource.

For example, you can set labels as follows:

```yaml
coordinator:
  [...]
  labels:
    example-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`labels`](#labels) section of this reference.

### Load Balancer

#### `service.internalLoadBalancer`

Type: Boolean

By default, this value is not set, which defaults to `false`.

When enabling this property, additional annotations are added to the pod for using an internal IP for the load balancer. Specifically, the following annotations are added which provide support for AWS, AKS, and GKE load balancers:

- `service.beta.kubernetes.io/azure-load-balancer-internal: "true"`
- `cloud.google.com/load-balancer-type: "Internal"`
- `service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0`

If these values are not applicable for your Kubernetes cluster, use the [`service.annotations`](#serviceannotations) value to provide a custom annotation that applies to your load balancer.

#### `service.loadBalancerIP`

Type: String

By default, this value is not set.

When setting this property, the load balancer attempts to use the provided IP address instead of dynamically allocating one. This IP address should be a static IP address that is usable by Kubernetes.

## Zookeeper Values

### Image Configuration

#### `zookeeper.image`

Type: String

By default, the value is set to `zookeeper`.

The `image` refers to the location to retrieve the specific container image for Zookeeper. In some cases, the `zookeeper.image` value may vary in corporate environments where there may be a private container registry that is used.

#### `zookeeper.imageTag`

Type: String

By default, the value is set to `3.8.0`.

The version of Zookeeper set has been validated by Dremio to work with the Dremio software. Changing this version is not recommended unless the tag is different due to a private container registry name difference.

### General Configuration

#### `zookeeeper.cpu` & `zookeeper.memory`

Type: Integer

By default, the value of `cpu` is `0.5` and the value of memory is `1024` (MB).

The values for `cpu` and `memory` control the amount of CPU and memory in MB being requested for each Zookeeper instance for the purposes of scheduling a Zookeeper to a specific node in the Kubernetes cluster.

#### `zookeeper.count`

Type: Integer

By default, the value is set to `3`.

This number sets the number of instances of Zookeeper to deploy. It is recommended to have a minimum of 3 to maintain a quorum. Changing the value below 3 may cause instability in the cluster.

#### `zookeeper.volumeSize`

Type: String

By default, the value is set to `10Gi`.

The Zookeeper volume is used for the WAL (Write Ahead Log) used by Zookeeper in the event of a crash.

### Annotations, Labels, Node Selectors, Tags, and Tolerations

By default, these values are not set. If the value is omitted or set to an empty array/dictionary, this value will be inherited from the top level equivalent. For more information about these configuration values, please refer to the top level equivalents of these values.

#### `zookeeper.annotations`

Type: Dictionary

The annotations set are used by the Zookeeper `StatefulSet` resource.

For example, you can set annotations as follows:

```yaml
zookeeper:
  [...]
  annotations:
    example-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`annotations`](#annotations) section of this reference.

#### `zookeeper.podAnnotations`

Type: Dictionary

The pod annotations set are used by all `Pod`(s) created by the Zookeeper `StatefulSet`.

For example, you can set pod annotations as follows:

```yaml
zookeeper:
  [...]
  podAnnotations:
    example-pod-annotation-one: "example-value-one"
[...]
```

More Info: Refer to the [`podAnnotations`](#podannotations) section of this reference.

#### `zookeeper.labels`

Type: Dictionary

The labels set are used by the Zookeeper `StatefulSet` .

For example, you can set labels as follows:

```yaml
zookeeper:
  [...]
  labels:
    example-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`labels`](#labels) section of this reference.

#### `zookeeper.podLabels`

Type: Dictionary

The pod labels set are used by all  `Pod`(s) created by the Zookeeper `StatefulSet`.

For example, you can set pod labels as follows:

```yaml
zookeeper:
  [...]
  podLabels:
    example-pod-label-one: "example-value-one"
[...]
```

More Info: Refer to the [`podLabels`](#podlabels) section of this reference.

#### `zookeeper.nodeSelector`

Type: Array

The node selectors set are used by all `Pod`(s) created by the Zookeeper `StatefulSet`.

For example, you can set node selectors as follows:

```yaml
zookeeper:
  [...]
  nodeSelector:
    diskType: "ssd"
[...]
```

More Info: Refer to the [`nodeSelector`](#nodeselector) section of this reference.

### Advanced Customizations

#### `zookeeper.storageClass`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `storageClass`.

Storage class has an impact on the performance of the Zookeeper instances when writing the WAL and reading back data in the event of a crash. A more performant storage class may impact recovery times in the event of such a crash.

More Info: Refer to the [`storageClass`](#storageclass) section of this reference.

#### `zookeeper.serviceAccount`

Type: String

By default, this value is not set. If this value is omitted or set to an empty string, this value will be inherited from the top level `serviceAccount`.

More Info: Refer to the [`serviceAccount`](#serviceaccount) section of this reference.
