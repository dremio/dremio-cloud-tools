# Using Persistent Storage for the Master Coordinator

To dynamically provision persistent storage for the Master Coordinator,
a Container Storage Interface (CSI) will need to be installed into the Kubernetes cluster.

### CSI Setup
The Container Storage Interface (CSI) will need to be installed in the Kubernetes cluster. The CSI is installed by
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
    provider: aws
    # When using AWS, the fileSystemId of the EFS Volume must be provided
    parameters:
      fileSystemId: fs-test
```
