# Automated Backups

### Prerequisites
* Distributed storage with [proper authentication configuration per specific cloud vendor](https://github.com/dremio/dremio-cloud-tools/blob/master/charts/dremio_v2/docs/Values-Reference.md#credentials-for-aws-s3)
* For GCP, create a `backups` folder in your bucket

To enable automated backups, uncomment the `backups` section in `values.yaml`

```
# To enable regularly scheduled backups, uncomment the following lines.
backups:
  enabled: true
  schedule: "0 2 * * *"
```
