# Dremio Administration

Administration commands restore, cleanup and set-password in dremio-admin needs to be run when the Dremio cluster is not running. So, before running these commands, you need to shutdown the Dremio cluster.

As part of the Helm chart, we support invoking the `dremio-admin` commands via a `dremio-admin` pod. Consult the [Admin CLI](https://docs.dremio.com/advanced-administration/dremio-admin-cli.html) documentation for Dremio for a complete list of `dremio-admin` commands that can be invoked.

**Starting Dremio Admin Pod**

The `dremio-admin` pod is created via the Helm chart. During this process, Dremio will become unavailable to end users as the other pods are shutdown during this process.

To invoke the `dremio-admin` pod, use the following Helm command:

```bash
$ helm upgrade <release-name> dremio_v2 --reuse-values --set DremioAdmin=true
```

**Stopping Dremio Admin Pod**

To stop the `dremio-admin` pod and restart the other Dremio pods, use the following Helm command:

```bash
$ helm upgrade <release-name> dremio_v2 --resuse-values --set DremioAdmin=false
```

**Connecting to the Dremio Admin Pod**

Once you have started the `dremio-admin` pod, you can use the following command to access the pod:

```bash
$ kubectl exec -it dremio-admin -- bash
```

The above command will connect you to the dremio-admin pod. Once there, you can invoke the `dremio-admin` commands normally from within the pod.

**Copying Files**

To copy contents from the `dremio-admin` pod, you can use the following command:

```bash
$ kubectl cp dremio-admin:<directory> <local-directory>
```

For example, to copy the contents of the Dremio `db` directory to a `db_backup` directory on your local machine, you can do the following:

```bash
$ kubectl cp dremio-admin:data/db db_backup
```
