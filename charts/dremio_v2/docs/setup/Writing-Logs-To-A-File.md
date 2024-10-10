# Writing Logs to a File

By default, logs are written to `stdout`. Logs can also be written to `/opt/dremio/log` by enabling `writeLogsToFile`. For more configuration information, see the [Values Reference](./Writing-Logs-To-A-File.md) documentation.

***Important Note:*** Upgrading an existing Dremio deployment can potentially be a destructive change since enabling this feature
requires an uninstall/install instead of a typical `helm upgrade`. Prior to enabling this feature, switch the cluster into
[Dremio Admin Mode](https://github.com/dremio/dremio-cloud-tools/blob/master/charts/dremio_v2/docs/administration/Dremio-Administration.md) and
perform a [back-up](https://docs.dremio.com/current/admin/cli/backup/).

To upgrade an existing deployment to write logs to files:
```bash
$ helm uninstall <release-name>
$ helm install <release-name> dremio_v2 -f values.yaml
```