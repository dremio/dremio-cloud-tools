# Dremio + Kubernetes Cluster Setup

## Overview

This is a Helm chart to deploy a Dremio cluster in K8S. It uses a persistent volume for the master node. An appropriate distributed file store (S3, ADLS, HDFS, etc) should be used for paths.dist as this deployment will lose locally persisted reflections and uploads.

This assumes you already have K8S cluster setup, kubectl configured to talk to your K8S cluster and
helm setup in your cluster.

Review and update values.yaml to reflect values for your environment before installing the helm chart.

#### Installing the helm chart
You need to run this from the charts directory
```bash
cd charts
helm install --wait dremio
```

#### Connect to the Dremio UI
You can access the Dremio UI on the port exposed on the node. For example in the
output below, if the dremio-coordinator is running on localhost, you can get to
Dremio UI using:

http://localhost:30630


```bash
kubectl get services dremio-coordinator-ui
NAME                    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
dremio-coordinator-ui   NodePort   10.110.65.97   <none>        9047:30630/TCP   1h
```

If you have used a LoadBalancer (see values.yaml) and there is an EXTERNAL-IP listed, you can
launch the Dremio UI using the external ip. So, in the example below, it will be:

http://35.226.31.211:9047

```bash
kubectl get services dremio-coordinator-ui
NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)          AGE
dremio-coordinator-ui   LoadBalancer   10.111.123.241   35.226.31.211  9047:31023/TCP   18m
```

#### Expose Dremio Client Port
This is used for ODBC and JDBC connections.

```bash
kubectl get services dremio-client
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
dremio-client   NodePort   10.97.16.239   <none>        31010:31823/TCP   1h
```

#### Scale by adding additional Coordinators or Executors (optional)
Get the name of the release. In the example below, the release name is quarreling-sponge.
```bash
helm list
NAME             	REVISION	UPDATED                 	STATUS  	CHART       	NAMESPACE
plundering-alpaca	1       	Wed Jul 18 09:36:14 2018	DEPLOYED	dremio-2.0.5	default
```

Add additional coordinators
```bash
helm upgrade <release name> dremio --set coordinator.count=3
```

Add additional executors
```bash
helm upgrade <release name> dremio --set executor.count=5
```

You can also scale down the same way.
