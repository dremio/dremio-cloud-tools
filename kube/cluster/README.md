# Dremio + Kubernetes Cluster Setup

## Overview

This includes a set of simple K8s templates to deploy a Dremio cluster. It uses a persistent volume for the master node. This is a framework to start from when deploying Dremio using Kubernetes. An appropriate distributed file store (S3, ADLS, HDFS, etc) should be used for paths.dist as this deployment will lose locally persisted reflections and uploads.

#### tldr;
```
kubectl create -f zookeeper.yaml
kubectl create -f dremio-configmap-minimum.yaml
kubectl create -f dremio-master-volume-hostpath.yaml
kubectl create -f dremio-master-volume-pvc.yaml
kubectl create -f dremio-master.yaml
kubectl create -f dremio-service-ui.yaml
kubectl create -f dremio-service-client.yaml
kubectl create -f dremio-executor.yaml
kubectl scale --replicas=5 rs/dremio-executor
```

## How To

To set up a cluster, run the following commands. This assumes that you already have [kubectl installed](https://kubernetes.io/docs/tasks/tools/install-kubectl/). This should work on any Kubernetes cluster (including [minikube](https://github.com/kubernetes/minikube)). For different systems, the master PersistentVolume should be configured differently.

#### Setup Zookeeper

```bash
kubectl create -f zookeeper.yaml
```

Zookeeper is used by Dremio for coordination purposes. While Dremio also supports running an embedded Zookeeper, that should only be used for development and trial purposes. This will start a single node Zookeeper. In reality, for redundancy, you would likely want to update this to have a 3 node Zookeeper quorum. As part of this configuration, a new service is made available for Dremio using the hostname zk-hs (Zookeeper headless service).

#### Setup the Dremio ConfigMap for Key Settings

```bash
kubectl create -f dremio-configmap-minimum.yaml
```

Dremio comes with two default ConfigMaps:

* dremio-configmap-minimum.yaml: Used for a minimum install
* dremio-configmap-micro.yaml: Used for trying out recipe (e.g. in Minikube)

You should install one or create/update for your configuration settings. Note that while this currently resizes the memory settings of the JVM, it doesn't request the right size containers from K8s.


#### Setup a Dremio Master Node with Hostpath Persistent Storage

```bash
kubectl create -f dremio-master-volume-hostpath.yaml
kubectl create -f dremio-master-volume-pvc.yaml
kubectl create -f dremio-master.yaml
```
In this example, we're using hostpath storage. For deployments outside of `minikube`, use the appropriate PersistentVolume type for your Kubernets location.

#### Setup a Dremio Executor ReplicaSet

```bash
kubectl create -f dremio-executor.yaml
```

Note, this initially defaults to a single node. Once created, you can scale up the ReplicaSet:

```bash
kubectl scale --replicas=5 rs/dremio-executor
```

#### Setup Dremio Services

```bash
kubectl create -f dremio-service-ui.yaml
kubectl create -f dremio-service-client.yaml
```

Load balancers: this doesn't configure a load balancer because that isn't available on `minikube`. In most setups, you would ensure that these services use a load balancer. 

#### Connect to the Dremio UI

If you are using `minikube`, simply run

```bash
minikube service dremio-coordinator-ui
```

If you are not running `minikube`, you need to look at the service information to determine the right ip/port to access.

```bash
$kubectl get service dremio-coordinator-ui

NAME                    CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
dremio-coordinator-ui   10.105.172.145   <nodes>       9047:30822/TCP   19h
```

#### Expose Dremio Client Port
This is used for ODBC and JDBC connections.

#### Add Additional Coordinator Slaves (optional)

If you want a ReplicaSet for slave coordinators, you can run:

```bash
kubectl create -f dremio-coordinator.yaml
```

This starts a single slave coordinator. You can then use normal kubectl tools to scale the ReplicaSet as necessary.

