# Scaling Coordinators and Executors

**Temporarily Scaling Coordinators and Executors**

*Coordinators*: To temporarily scale the coordinator nodes that you have, modify the number of replicas for the `dremio-coordinator` StatefulSet using the following command.

```bash
$ kubectl scale statefulsets dremio-coordinator --replicas=<number>
```

This number should represent the number of *secondary* coordinators that you want. Setting this number to zero will remove all secondary coordinators and leave a single master coordinator.

*Executors*: To temporarily scale the number of executors, locate the StatefulSet for the engine you wish to scale.

To see the StatefulSets that exist, use the following command:

```bash
$ kubectl get statefulsets
```

Then, to scale a specific engine, modify the number of replicas for the associated StatefulSet using the following command:

```bash
$ kubectl scale statefulsets <stateful-set> --replicas=<number>
```

**Permanently Scaling Coordinators and Executors**

1. Get the name of the Helm release. In the example below, the release name is `dremio`:

```bash
$ helm list
NAME  	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART       	APP VERSION
dremio	helm-demo	1       	2020-08-10 08:45:20.038011 -0700 PDT	deployed	dremio-2.0.0	           
```

Adding additional resources should be done by modifying your`values.local.yaml` file.

* To modify the number of secondary coordinators, modify the value `coordinator.count` to be greater than 0.
* To modify the number of executors, modify the `executor.count`. If you have more than one engine and wish to scale a specific engine, see the [`executor.engineOverride`](../Values-Reference.md#executorengineoverride) section of the `Values.yaml` Reference documentation.

Once you have made the appropriate customizations, run the following command to update your deployment with the changes:

```bash
$ helm upgrade <release-name> dremio_v2 -f values.local.yaml
```

