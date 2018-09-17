# Dremio + Kubernetes Cluster Setup

## Overview

This is a Helm chart to deploy a Dremio cluster in kubernetes. It uses a persistent volume for the master node. An appropriate distributed file store (S3, ADLS, HDFS, etc) should be used for paths.dist as this deployment will lose locally persisted reflections and uploads.

This assumes you already have kubernetes cluster setup, kubectl configured to talk to your kubernetes cluster and helm setup in your cluster.

Review and update values.yaml to reflect values for your environment before installing the helm chart. This is specially important for for the memory and cpu values - your kubernetes cluster should have sufficient resources to provision the pods with those values. If your kubernetes installation does not support serviceType LoadBalancer, it is recommended to comment the serviceType value in values.yaml file before deploying.

#### Installing the helm chart
Run this from the charts directory
```bash
cd charts
helm install --wait dremio
```
If it takes longer than a couple of minutes to complete, check the status of the pods to see where they are waiting. If they are pending scheduling due to limited memory or cpu, either adjust the values in values.yaml and restart the process or add more resources to your kubernetes cluster. 

#### Connect to the Dremio UI
If your kubernetes supports serviceType LoadBalancer, you can get to the Dremio UI on the load balancer external ip. 

For example, if your service output is:

```bash
kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   LoadBalancer   10.99.227.180   35.226.31.211     31010:32260/TCP,9047:30620/TCP   2d
```

you can get to the Dremio UI using the value under column EXTERNAL-IP:

http://35.226.31.211:9047

If your kubernetes does not have support of serviceType LoadBalancer, you can access the Dremio UI on the port exposed on the node. For example, if the service output is:

```bash
kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   NodePort       10.110.65.97    <none>            31010:32390/TCP,9047:30670/TCP   1h
```
where there is no external ip and the Dremio master is running on node "localhost", you can get to Dremio UI using:

http://localhost:30670


#### Dremio Client Port
The port 31010 is used for ODBC and JDBC connections. You can look up service dremio-client in kubernetes to find the host to use for ODBC or JDBC connections. Depending on your kubernetes cluster supporting serviceType LoadBalancer, you will use the load balancer external-ip or the node on which a coordinator is running.

```bash
kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   LoadBalancer   10.99.227.180   35.226.31.211     31010:32260/TCP,9047:30620/TCP   2d
```

For example, in the above output, the service is exposed on an external-ip. So, you can use 35.226.31.211:31010 in your ODBC or JDBC connections. 

#### Scale by adding additional Coordinators or Executors (optional)
Get the name of the release. In the example below, the release name is plundering-alpaca.
```bash
helm list
NAME             	REVISION	UPDATED                 	STATUS  	CHART       	NAMESPACE
plundering-alpaca	1       	Wed Jul 18 09:36:14 2018	DEPLOYED	dremio-0.0.5	default
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
