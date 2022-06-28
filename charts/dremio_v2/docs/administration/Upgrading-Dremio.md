# Upgrading Dremio

1. Ensure that you have completed a backup of Dremio. See the [Dremio Administration](./Dremio-Administration.md) documentation on how to access `dremio-admin` commands to complete a backup prior to upgrading.
2. Update the Dremio `imageTag` value in your values.yaml file.

   For example, to update to `4.7.0`, update the tag to the following:

```yaml
imageTag: 4.7.0
[...]
```

3. Get the name of the Helm release. In the example below, the release name is `dremio`.

```bash
$ helm list
NAME  	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART       	APP VERSION
dremio	helm-demo	1       	2020-08-10 08:45:20.038011 -0700 PDT	deployed	dremio-2.0.0	           
```

4. Upgrade the deployment via `helm` upgrade command:

```bash
$ helm upgrade <release-name> dremio_v2 -f values.local.yaml
```

The existing pods will be terminated and new pods will be created with the new image. You can monitor the status of the pods by running:

```bash
$ kubectl get pods
```

Once all the pods are restarted and running, your Dremio cluster is upgraded.