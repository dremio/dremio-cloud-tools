# Writing Logs to a File

By default, logs are written to `stdout`. Logs can also be written to `/opt/dremio/log` by enabling `writeLogsToFile`.
For more configuration information, see the [Values Reference](./Writing-Logs-To-A-File.md) documentation.

To upgrade an existing deployment to write logs to files:
```bash
$ helm uninstall <release-name> dremio_v2 -f values.yaml
$ helm install <release-name> dremio_v2 -f values.yaml
```