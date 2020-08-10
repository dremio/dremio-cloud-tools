# Important Setup Considerations

As part of setting up a Dremio cluster on Kubernetes, there are a number of important considerations that we recommend you review before deploying your cluster. Some of these values have an impact on the performance of your cluster and should be adjusted to your needs.

* `imageTag`: As part of setup, this value should be updated to reference the exact version of Dremio you wish to deploy, i.e. `4.7.0`.
* `distStorage.type`: By default, the `distStorage.type` is set to `local`. This **must** be changed prior to production use. We do not recommend users use local distributed storage as part of a production setup.
* `volumeSize` and `storageClass`: The size and type of volume used for Dremio has a direct impact on performance. In most Kubernetes providers, volume size has a direct impact on the performance in IOPS and read/write speeds. It is important to check your Kubernetes provider to determine how volume size impacts the performance of your disk.
* `executor.cloudCache.storageClass`: Dremio C3 was designed to be used with performant NVMe storage. By default, the chart utilizes the default storage class that is configured on the Kubernetes cluster. For the major Kubernetes providers, NVMe storage is often available on appropriately sized nodes. We recommend utilizing a local storage provisioner to unlock the benefits of NVMe storage available on the physical Kubernetes nodes. For more information, see the [Kubernetes Special Interest Group for Local Static Provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner).

For users who wish to setup a Hive 2/3 source, please see the [Setup Hive 2 and 3](./Setup+Hive+2+and+3.md) documentation.