# Migrating Helm Chart Versions

**⚠️ If the contents of your chart's `templates` directory has been modified, this guide may not cover the changes necessary to maintain your existing setup.** As new functionality has been added to the Helm chart, please check whether the new version of the chart allows you to express the same modifications that have been made to your templates directory.

**Note**: Helm 2 is no longer supported in this Helm chart.

1. First begin by updating the `values.yaml` to reflect the original chart's values.

In the new version of the Dremio Helm chart, changes have been introduced to the `values.yaml` file that differ from the original Dremio Helm chart. The chart below maps existing values and shows their equivalents in this Helm chart's `values.yaml`.

| Original Value                        | New Value                                                    |
| ------------------------------------- | ------------------------------------------------------------ |
| `executor.cloudCache.quota.fs_pct`    | **Removed** - In the new chart, we now require provisioning a persistent volume for Cloud Cache. |
| `executor.cloudCache.quota.db_pct`    | **Removed** - In the new chart, we now require provisioning a persistent volume for Cloud Cache. |
| `executor.cloudCache.quota.cache_pct` | **Removed** - In the new chart, we now require provisioning a persistent volume for Cloud Cache. |
| `tls.ui.enabled`                      | `coordinator.ui.tls.enabled`                                 |
| `tls.ui.secret`                       | `coordinator.ui.tls.secret`                                  |
| `tls.client.enabled`                  | `coordinator.client.tls.enabled`                             |
| `tls.client.secret`                   | `coordinator.client.tls.secret`                              |
| `serviceType`                         | `service.type`                                               |
| `sessionAffinity`                     | `service.sessionAffinity`                                    |
| `internalLoadBalancer`                | `service.internalLoadbalancer`                               |
| `imagePullSecrets`                    | `imagePullSecrets` is no longer a string based-value. This is now an array, which can be represented as follows: `imagePullSecrets:  ["original-value"]`. |
| `distStorage.aws.accessKey`           | `distStorage.aws.credentials.accessKey`  ***Note***: If using access key and secret for authentication, the value of `distStorage.aws.authentication` must also be set to `accesskeySecret`. |
| `distStorage.aws.secret`              | `distStorage.aws.credentials.secret` ***Note***: If using access key and secret for authentication, the value of `distStorage.aws.authentication` must also be set to `accesskeySecret`. |
| `distStorage.azure.applicationId`     | `distStorage.azure.credentials.applicationId`                |
| `distStorage.azure.secret`            | `distStorage.azure.credentials.secret`                       |
| `distStorage.azure.oauth2EndPoint`    | `distStorage.azure.credentials.oauth2Endpoint` ***Note***: The capitalization has changed in this value from `EndPoint` to `Endpoint`. |
| `distStorage.azureStorage.accessKey`  | `distStorage.azureStorage.credentials.accessKey`             |

2. This chart introduces the concept of engines. Engines operate as a grouping of executor nodes that can be targeted via queues to handle specific workloads.

As part of the transition to this Helm chart, to retain the existing persistent volumes used for the executor nodes, ensure that you keep a `default` engine as provided by the `values.yaml`. Additionally, set the value of `executor.engineOverride.default.volumeClaimName` to be `dremio-executor-volume`.

For example, you would want to do the following to setup the `volumeClaimName`:

```yaml
executor:
  [...]
  engineOverride:
    default:
      volumeClaimName: dremio-executor-volume
```

3. Following updating `values.yaml`, we are now ready to upgrade between Helm charts.

Begin by uninstalling the existing Helm chart for Dremio by using the `helm` command. (Note: The data will persist in the persistent volumes through this process.)

```bash
$ helm uninstall <release-name>
```

Now, invoke `helm` again:

```bash
$ helm install <release-name> <chart-directory>
```

4. Verify that the upgrade was successful.