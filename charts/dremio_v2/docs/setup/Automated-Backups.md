# Automated Backups

### Prerequisites
* Distributed storage with [proper authentication configuration per specific cloud vendor](https://github.com/dremio/dremio-cloud-tools/blob/master/charts/dremio_v2/docs/Values-Reference.md#credentials-for-aws-s3)
* For GCP, create a folder named `backups` at the path specified at `distStorage.gcp.path` in your bucket

To enable automated backups, uncomment the `backups` section in `values.yaml`

```
# To enable regularly scheduled backups, uncomment the following lines.
backups:
  schedule: "0 2 * * *"
```

### Restore a Backup
The cluster needs to be switched into Admin Mode. To switch the cluster into Admin Mode, run
the following command

```
helm upgrade DREMIO_RELEASE . -f VALUES --set DremioAdmin=true -n NAMESPACE
```
* DREMIO_RELEASE: name of the Dremio Helm Release
* VALUES: path to values.yaml
* NAMESPACE: Kubernetes namespace for Dremio

Connect to the Admin Pod
```
kubectl exec -it dremio-admin -- /bin/bash
```

Delete the contents of `DREMIO_LOCAL_DATA_PATH` and then create an empty directory called db that is
readable and writable by the user running restore and by the Dremio daemon under `DREMIO_LOCAL_DATA_PATH`

Next, restore the backup
```
/opt/dremio/bin/dremio-admin restore -d FILE_SYSTEM:///BUCKET_NAME/PATH/backups/BACKUP_FILE
```

* FILE_SYSTEM: Options are `dremioS3`, `dremiogcs` and `dremioAzureStorage`
* BUCKET_NAME: name of your distributed storage object
* PATH: The path, relative to the filesystem, for Dremio's directories
* BACKUP_FILE: name of the backup file to restore

Finally, disabled Admin Mode
```
helm upgrade DREMIO_RELEASE . -f VALUES --set DremioAdmin=false -n NAMESPACE
```
* DREMIO_RELEASE: name of the Dremio Helm Release
* VALUES: path to values.yaml
* NAMESPACE: Kubernetes namespace for Dremio
