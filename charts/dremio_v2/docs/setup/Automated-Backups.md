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
