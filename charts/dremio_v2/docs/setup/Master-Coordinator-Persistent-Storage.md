# Using Persistent Storage for the Master Coordinator

You may want to use a persistent file store provided by your cloud vendor for the Master Coordinator.
To dynamically provision persistent storage for the Master Coordinator, we will utilize
a Container Storage Interface (CSI) provided by your cloud vendor.

### CSI Setup
The Container Storage Interface (CSI) will need to be installed in your cluster. The CSI is installed by
default in Azure clusters. See instructions below for GCP and AWS.
* [GCP](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver#enabling_the_on_an_existing_cluster)
* [AWS](https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html)

### Enabling Persistent Storage
Persistent storage can be enabled in `values.yaml`. Example:
```
# values.yaml

masterCoordinator:
  persistentStorage:
    # Options are: gcp, aws, azure
    provider: gcp
```

For Azure, we can optionally configure storage class redundancy. More information about available storage classes
[can be found here](https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#create-a-storage-class)

Azure storage class can be configured in `values.yaml`. Example:
```
# values.yaml

masterCoordinator:
  persistentStorage:
    provider: azure
    skuName: Standard_GRS
```
