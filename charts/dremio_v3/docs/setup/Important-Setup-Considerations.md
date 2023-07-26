# Important Setup Considerations

As part of setting up a Dremio cluster on Kubernetes, there are a number of important considerations that we recommend you review before deploying your cluster. Some of these values have an impact on the performance of your cluster and should be adjusted to your needs.

* `imageTag`: As part of setup, this value should be updated to reference the exact version of Dremio you wish to deploy, i.e. `4.7.0`. If you are directly consuming Dremio's images from Docker Hub, when specifying which version to use, it is recommended to use the full version tag in the form `X.Y.Z` (i.e. `21.1.0`), as image tags in the form `X.Y` (i.e. `21.1`) are continually updated with the latest patch version released.
* `distStorage.type`: By default, the `distStorage.type` is set to `local`. This **must** be changed prior to production use. We do not recommend users use local distributed storage as part of a production setup.
* `volumeSize` and `storageClass`: The size and type of volume used for Dremio has a direct impact on performance. In most Kubernetes providers, volume size has a direct impact on the performance in IOPS and read/write speeds. It is important to check your Kubernetes provider to determine how volume size impacts the performance of your disk.
* `executor.cloudCache.storageClass`: Dremio C3 was designed to be used with performant NVMe storage. By default, the chart utilizes the default storage class that is configured on the Kubernetes cluster. For the major Kubernetes providers, NVMe storage is often available on appropriately sized nodes. We recommend utilizing a local storage provisioner to unlock the benefits of NVMe storage available on the physical Kubernetes nodes. For more information, see the [Kubernetes Special Interest Group for Local Static Provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner).
* `service.sessionAffinity`: By default, the `service.sessionAffinity` is set to `false`. We currently recommend leaving this value as `false` unless you are using Flight, in which case you should consider the following factors:
  * When the Flight client is being used and this value is set to `false`, there are cases where the `DoGet` call happens on a different TCP connection than the original `GetFlightInfo` call.
    * For the Java Flight client, this happens when a different `ManagedChannel` is used for different `FlightClient` instances for different Dremio Users.
    * For the Python Flight client, this happens when a different `FlightClient` is initialized for different Dremio Users.
  * In the cases described above, the `DoGet` call goes to a different coordinator than the one that originally created the query plan.
  * This causes the query plan to be regenerated, which is less efficient than the case where both the `DoGet` and the `GetFlightInfo` calls go to the same coordinator.
  * When `service.sessionAffinity` is set to `true`, all the TCP connections from a particular client IP will be routed to a specific Dremio coordinator.

For users who wish to setup a Hive 2/3 source, please see the [Setup Hive 2 and 3](./Setup-Hive-2-and-3.md) documentation.