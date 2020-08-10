# Setup Hive 2 and 3

To setup Hive 2/3 in the Helm chart, locate the respective `config/hive2` or `config/hive3` directory to copy your necessary configuration files for Hive, i.e. `core-site.xml`.

To update the configuration files in the pods, run the Helm upgrade command:

```bash
$ helm upgrade <release-name> dremio_v2 -f values.local.yaml
```