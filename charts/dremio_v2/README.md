# Dremio on Kubernetes Installation Guide

Before beginning to setup Dremio on Kubernetes, take a moment to review all the associated [documentation](./docs) for the Helm chart.

Once you have reviewed the documentation, continue to the [Installation](#installation) steps below to get your Dremio cluster up and running. If you are upgrading from the previous Helm chart for Dremio, please see the [Migrating Helm Chart Versions](./docs/setup/Migrating-Helm-Chart-Versions.md) documentation.

## Installation

#### Prerequisites

This guide assumes you already have the following setup:

* An existing Kubernetes cluster setup
* Local machine setup with Helm 3
* Local `kubectl` configured to access your Kubernetes cluster

#### Installing the Helm Chart

1. Review the default values provided in `values.yaml` and review the [Important Setup Considerations](./docs/setup/Important-Setup-Considerations.md) documentation for the Helm chart.

For a complete reference on all the options available in the `values.yaml`, see the [`Values.yaml` Reference](./docs/Values-Reference.md) documentation — this document covers all the available options and provides small code samples for each configuration option.

To customize the Dremio software configuration, see the [Customizing Dremio Configuration](./docs/setup/Customizing-Dremio-Configuration.md) documentation.

***Tip***: As a best practice, we recommend creating a `values.local.yaml` (or equivalently named file) that stores the values that you wish to override as part of your setup of Dremio. This allows you to quickly update to the latest version of the chart by copying the `values.local.yaml` across Helm chart updates.

2. To install, run the following from the `charts` directory:

```bash
$ cd charts
$ helm install <release-name> dremio_v2 -f values.local.yaml
```

3. Check the status of the installation using the following command:

```bash
$ kubectl get pods
```

If it takes longer than a couple of minutes to complete, check the status of the pods to see where they are waiting. If they are stuck in Pending state for an extended period of time, check on the status of the pod to check that there is sufficient resources for scheduling. To check, use the following command on the pending pod:

```bash
$ kubectl describe pods <pod-name>
```

If the events at the bottom of the output mention insufficient CPU or memory, either adjust the values in your `values.local.yaml` and restart the process or add more resources to your Kubernetes cluster.

4. Once you see all the pods in a "ready" state, your setup is all done! See below on how to connect to the Dremio UI to get your first user setup and also how to connect via JDBC/ODBC.

#### Connect to the Dremio UI

If your Kubernetes cluster supports a `service.type` of `LoadBalancer`, you can access the Dremio UI via the load balancer's external IP.

For example, if your service output is:

```bash
$ kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   LoadBalancer   10.99.227.180   35.226.31.211     31010:32260/TCP,9047:30620/TCP   2d
```

You can get to the Dremio UI using the value under column EXTERNAL-IP:

http://35.226.31.211:9047

If your Kubernetes cluster does not have support for a `service.type` of `LoadBalancer`, you can access the Dremio UI on the port exposed on the node. 

For example, if the service output is:

```bash
$ kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   NodePort       10.110.65.97    <none>            31010:32390/TCP,9047:30670/TCP   1h
```

Where there is no external IP and the Dremio master is running on node "localhost", you can get to Dremio UI using:

http://localhost:30670

#### Connect to Dremio via ODBC/JDBC

The port 31010 is used for ODBC and JDBC connections. You can look up the service `dremio-client` in Kubernetes to find the host to use for ODBC or JDBC connections. Depending on your Kubernetes cluster's support for load balancers, you will use the load balancer external IP or the node on which a coordinator is running.

```bash
$ kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   LoadBalancer   10.99.227.180   35.226.31.211     31010:32260/TCP,9047:30620/TCP   2d
```

For example, in the above output, the service is exposed on an external IP. So, you can use `35.226.31.211:31010` in your ODBC or JDBC connections.