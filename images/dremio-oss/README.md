# Dremio Docker Image
## Image Build

You can build this image by identifying a Dremio download tarball download URL and then running the following command:

``` bash
docker build --build-arg DOWNLOAD_URL=<URL> -t "dremio-oss:2.0.5" .
```

Note: This should work for both Community and Enterprise editions of Dremio.

---

## Single Node Deployment

```bash
docker run -p 9047:9047 -p 31010:31010 -p 45678:45678 dremio/dremio-oss
```
This includes a single node deployment that starts up a single daemon that includes:
* Embedded Zookeeper
* Master Coordinator
* Executor

---

## Distributed Deployment

To run Dremio in a distributed deployment, you should create a separate zookeeper quorum that Dremio uses. You can do this using the [Zookeeper](https://hub.docker.com/_/zookeeper/) image.

### Coordinator (master)

You only need one of these.

```bash
docker run -p 9047:9047 -p 31010:31010 -p 45678:45678 dremio/dremio-oss -Dz \
  -Dzookeeper=my_zk_quorum \
  -Dservices.coordinator.master.embedded-zookeeper.enabled=false \
  -Dservices.executor.enabled=false
```

### Coordinator (slave)

You can have an unlimited number of these.

```bash
docker run -p 9047:9047 -p 31010:31010 -p 45678:45678 dremio/dremio-oss -Dz \
  -Dzookeeper=my_zk_quorum \
  -Dservices.coordinator.master.enabled=false \
  -Dservices.executor.enabled=false
```

### Executor

You can have an unlimited number of these.

```bash
docker run -p 45678:45678 dremio/dremio-oss -Dz \
  -Dzookeeper=my_zk_quorum \
  -Dservices.coordinator.enabled=false
```

---

## Dealing with name resolution in clusters
When having Dremio communicate information between nodes, you need to have Dremio use the name it registers in Zookeeper to be resolvable from other nodes. The easiest way to do this is to use IP addresses and set the following additional property: `-Dregistration.publish-host=$LOCAL_CONTAINER_IP`
