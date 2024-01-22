# Master Coordinator High Availability

Dremio clusters can be made highly available by configuring one active and a
backup coordinator node as a standby. For more detailed information about high availability,
[refer to additional documentation.](https://docs.dremio.com/current/get-started/cluster-deployments/architecture/high-availability/)

### Prerequisites
The Dremio Master Coordinator must be configured to use persistent storage provided by a cloud vendor. Please refer to
[documentation for additional setup information](https://github.com/dremio/dremio-cloud-tools/blob/master/charts/dremio_v2/docs/setup/Master-Coordinator-Persistent-Storage.md)

### Additional Configuration Parameters
Depending on the cloud provider, additional parameters must be provided

#### GCP
Provide the name of the `network` attached to the GKE Cluster. To retrieve the name of the `network` attached to the
Kubernetes cluster, navigate to the Details panel for the GKE cluster in the GCP console. Example:
```
# values.yaml

masterCoordinator:
  highAvailability:
    enabled: true
  persistentStorage:
    provider: gcp
    parameters:
      network: name-of-network
```

#### AWS
[Please refer to documentation for additional information](https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/efs-create-filesystem.md)
about EFS configuration and setup. Provide the `fileSystemId` of your EFS volume. Example:
```
# values.yaml

masterCoordinator:
  highAvailability:
    enabled: true
  persistentStorage:
    provider: aws
    parameters:
      fileSystemId: fs-id
```

### Enabling High Availability
High Availability can be enabled in `values.yaml`. Example:
```
# values.yaml

masterCoordinator:
  highAvailability:
    enabled: true
  # Persistent storage must be configured
  persistentStorage:
    # Options are: gcp, aws, azure
    provider: gcp
```
