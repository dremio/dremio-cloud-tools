# Dremio + Kubernetes Cluster Setup

## Overview

This is a Helm chart to deploy a Dremio cluster in kubernetes. It uses
a persistent volume for the master node to store the metadata for the
cluster. The default configuration uses the default persistent storage
supported by the kubernetes platform. For example,

| Kubernetes platform | Persistent store |
|---------------------|------------------|
| AWS EKS             | EBS              |
| Azure AKS           | Azure disk (HDD) |
| Google GKE          | Persistent Disk  |
| Local K8S on Docker | Hostpath         |

If you want to use a different storage class available in your
kubernetes environment, add the storageClass in values.yaml.

An appropriate distributed file store (S3, ADLS, HDFS, etc) should be
used for paths.dist as this deployment will lose locally persisted
reflections and uploads. You can update config/dremio.conf. Dremio
[documentation](https://docs.dremio.com/deployment/distributed-storage.html)
provides more information on this.

This assumes you already have kubernetes cluster setup, kubectl
configured to talk to your kubernetes cluster and helm setup in your
cluster. Review and update values.yaml to reflect values for your
environment before installing the helm chart. This is specially
important for for the memory and cpu values - your kubernetes cluster
should have sufficient resources to provision the pods with those
values. If your kubernetes installation does not support serviceType
LoadBalancer, it is recommended to comment the serviceType value in
values.yaml file before deploying.

#### Installing the helm chart

Review charts/dremio/values.yaml and adjust the values as per your
requirements. Note that the values for cpu and memory for the
coordinator and the executors are set to work with AKS on Azure with
worker nodes setup with machine types Standard_E16s_v3.

Run this from the charts directory

```bash
cd charts helm install --wait dremio ```

If it takes longer than a couple of minutes to complete, check the
status of the pods to see where they are waiting. If they are pending
scheduling due to limited memory or cpu, either adjust the values in
values.yaml and restart the process or add more resources to your
kubernetes cluster.

#### Connect to the Dremio UI

If your kubernetes supports serviceType LoadBalancer, you can get to
the Dremio UI on the load balancer external IP.  For example, if your
service output is:

```bash
kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   LoadBalancer   10.99.227.180   35.226.31.211     31010:32260/TCP,9047:30620/TCP   2d
```

You can get to the Dremio UI using the value under column EXTERNAL-IP:

http://35.226.31.211:9047

If your kubernetes does not have support of serviceType LoadBalancer,
you can access the Dremio UI on the port exposed on the node. For
example, if the service output is:

```bash
kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   NodePort       10.110.65.97    <none>            31010:32390/TCP,9047:30670/TCP   1h
```

Where there is no external IP and the Dremio master is running on node
"localhost", you can get to Dremio UI using:

http://localhost:30670

#### Dremio Client Port

The port 31010 is used for ODBC and JDBC connections. You can look up
service dremio-client in kubernetes to find the host to use for ODBC
or JDBC connections. Depending on your kubernetes cluster supporting
serviceType LoadBalancer, you will use the load balancer external-ip
or the node on which a coordinator is running.

```bash
kubectl get services dremio-client
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
dremio-client   LoadBalancer   10.99.227.180   35.226.31.211     31010:32260/TCP,9047:30620/TCP   2d
```

For example, in the above output, the service is exposed on an
external-ip. So, you can use 35.226.31.211:31010 in your ODBC or JDBC
connections.

#### Viewing logs

Logs are written to the container's console. All the logs -
server.log, server.out, server.gc and access.log - are written into
the console simultaneously. You can view the logs using kubectl.  ```
kubectl logs <container-name> ``` You can also tail the logs using the
-f parameter.  ``` kubectl logs -f <container-name> ```

#### Scale by adding additional Coordinators or Executors (optional)

Get the name of the helm release. In the example below, the release
name is plundering-alpaca:

```bash
helm list
NAME             	REVISION	UPDATED                 	STATUS  	CHART       	NAMESPACE
plundering-alpaca	1       	Wed Jul 18 09:36:14 2018	DEPLOYED	dremio-0.0.5	default
```

Add additional coordinators:

```bash
helm upgrade <release name> dremio --set coordinator.count=3
```

Add additional executors:

```bash
helm upgrade <release name> dremio --set executor.count=5
```

You can also scale down the same way.

### Running offline dremio-admin commands

Administration commands restore, cleanup and set-password in
dremio-admin needs to be run when the Dremio cluster is not
running. So, before running these commands, you need to shutdown the
Dremio cluster. Use the helm delete command to delete the helm
release.  (Kubernetes does not delete the persistent store volumes
when you delete statefulset pods and when you install the cluster
again using helm, the existing persistent store will be used and you
will get your Dremio cluster running again.)

After Dremio cluster is shutdown, start the dremio-admin pod using:

```bash
helm install --wait dremio --set DremioAdmin=true
```
Once the pod is running, you can connect to the pod using:

```bash
kubectl exec -it dremio-admin -- bash
```
Now, you have a bash shell from where you can run the dremio-admin commands.

Once you are done, you can delete the helm release for the
dremio-admin and start your Dremio cluster.

#### Upgrading Dremio

You should attempt upgrade when no queries are running on the
cluster. Update the Dremio image tag in your values.yaml file. E.g:

```bash
image: dremio/dremio-oss:3.0.0
...
```

Get the name of the helm release. In the example below, the release
name is plundering-alpaca.

```bash
helm list
NAME             	REVISION	UPDATED                 	STATUS  	CHART       	NAMESPACE
plundering-alpaca	1       	Wed Jul 18 09:36:14 2018	DEPLOYED	dremio-0.0.5	default
```

Upgrade the deployment via helm upgrade command:

```
helm upgrade <release name> .
```

Existing pods will be terminated and new pods will be created with the
new image. You can

monitor the status of the pods by running:
```
kubectl get pods
```

Once all the pods are restarted and running, your Dremio cluster is
upgraded.

#### Customizing Dremio configuration

Dremio configuration files used by the deployment are in the config
directory. These files are propagated to all the pods in the
cluster. Updating the configuration and upgrading the helm release -
just like doing an upgrade - would refresh all the pods with the new
configuration. [Dremio
documentation](https://docs.dremio.com/deployment/README-config.html)
covers the configuration capabilities in Dremio.

If you need to add a core-site.xml, you can add the file to the config
directory and it will be propagated to all the pods on install or
upgrade of the deployment.

#### Important Changes

2019-09-19 (v0.1.0): BREAKING CHANGE.

  Dremio versions before 4.0.0 are no longer supported by this Helm
  chart. Dremio image specifier was split into an imageName and
  imageTag parts to follow best practices.  "dist" value in
  dremio.conf moved to cloud storage where possible (otherwise
  defaults to pdfs) -- this will lose any previously extant
  reflections materialisations, user uploads, scratch files, etc.
  Also added Cloud Cache support (new in Dremio 4.0).  Please see
  values.yaml for details on this new configuration.
