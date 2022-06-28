# Customizing Dremio Configuration

Dremio configuration files used by the deployment are in the `config` directory. These files are propagated to all the pods in the cluster.

To update the configuration used in the pods, run the Helm upgrade command:

```bash
$ helm upgrade <release-name> dremio_v2 -f values.local.yaml
```

To see all the configuration customizations, please see the [Customizing Configuration](https://docs.dremio.com/deployment/README-config.html) documentation for Dremio.

For users who wish to setup a Hive 2/3 source, please see the [Setup Hive 2 and 3](./Setup-Hive-2-and-3.md) documentation.