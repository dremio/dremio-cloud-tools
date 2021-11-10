# Installing Dremio on Kubernetes

If you are upgrading from the previous Helm chart for Dremio, please see the [Migrating Helm Chart Versions](./docs/setup/Migrating-Helm-Chart-Versions.md) documentation.

## Prerequisites


* Ensure that you haven existing Kubernetes cluster. 
* Ensure that Helm 3 is set up on a local machine.
* Ensure that a local kubectl is configured to access your Kubernetes cluster.

## Procedure

1. Download [the `dremio-cloud-tools` repository](https://github.com/dremio/dremio-cloud-tools/tree/30bffb1320d63fb13d9aee56e9e0dbf5449337b0).
1. In a terminal window, cd to `dremio-cloud-tools/charts/dremio_v2/`.
1. Create a copy of the file `values.yaml` in the same directory. The rest of this procedure refers to the copy as `values.local.yaml`. Making changes in this copy allows you to quickly update to the latest version of the chart by copying the `values.local.yaml` across Helm chart updates.
1. Referring to "[`values.yaml` Reference](./docs/Values-Reference.md)", review the default values for configuring Dremio in the `values.local.yaml` file, and change values where necessary.
1. Review the document "[Important Setup Considerations](./docs/setup/Important-Setup-Considerations.md)" and make any of the listed changes to the values in your `values.local.yaml` file that you think are necessary for your enironment.
1. Install the Helm Chart by running this command from the `charts` directory:

   ```bash
   $ helm install <release-name> dremio_v2 -f values.local.yaml
   ```

   If the installation takes longer than a few minutes to complete, you can check the status of the installation by using the following command:

   ```bash
   $ kubectl get pods
   ```

   If a pod remains in **Pending** state for more than a few minutes, run the following command to view its status to check that there are sufficient resources for scheduling:

   ```bash
   $ kubectl describe pods <pod-name>
   ```

   If the events at the bottom of the output mention insufficient CPU or memory, either adjust the values in your `values.local.yaml` and restart the process or add more resources to your Kubernetes cluster.

   When all of the pods are in the **Ready** state, the installation is complete.

## What to do next

Now that you've installed the Dremio Helm chart, you can get the HTTP addresses for connecting to Dremio's UI, connecting to Dremio from BI tools via JDBC/ODBC, and for connecting to Dremio from BI tools via Apache Arrow Flight.

### Getting the HTTP address for connecting to the Dremio UI

Run the following command to use the `service dremio-client` in Kubernetes to find the host for the Dremio UI:

```
$ kubectl get services dremio-client
```

* If the value in the `TYPE` column of the output is `LoadBalancer`, access the Dremio UI through the address in the `EXTERNAL_IP` column and port 9047.
For example, in the output below, the value under the `EXTERNAL-IP` column is 8.8.8.8. Therefore, you can get to the Dremio UI via port 9047 on that address: http://8.8.8.8:9047
   ```
   $ kubectl get services dremio-client
   NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
   dremio-client   LoadBalancer   10.99.227.180   8.8.8.8           31010:32260/TCP,9047:30620/TCP   2d
   ```

   If you want to change the expose port on the load balancer, change the value of the setting `coordinator.web.port` in the file `values.local.yaml`.
* If the value in the TYPE column of the output is `NodePort`, access the Dremio UI through http://localhost:30670.

### Getting the HTTP address for using ODBC or JDBC to connect from BI tools to Dremio

Run the following command to use the `service dremio-client` in Kubernetes to find the host for JDBC/ODBC connections by using the following command:
```
$ kubectl get services dremio-client
```
* If the value in the TYPE column of the output is `LoadBalancer`, access Dremio using JDBC/ODBC through the address in the `EXTERNAL_IP` column and port 31010.
   For example, in the output below, the value under the `EXTERNAL-IP` column is 8.8.8.8. Therefore, you can get to the Dremio UI via port 9047 on that address: http://8.8.8.8:9047
   ```
   $ kubectl get services dremio-client
   NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
   dremio-client   LoadBalancer   10.99.227.180   8.8.8.8           31010:32260/TCP,9047:30620/TCP   2d
   ```
   If you want to change the expose port on the load balancer, change the value of the setting `coordinator.client.port` in the file `values.local.yaml`.

* If the value in the TYPE column of the output is `NodePort`, access Dremio using JDBC/ODBC through http://localhost:32390.

### Getting the HTTP address for using Apache Arrow Flight to connect from BI tools to Dremio

Run the following command to use the `service dremio-client` in Kubernetes to find the host for Apache Arrow Flight connections by using the following command:

```
$ kubectl get services dremio-client
```

* If the value in the TYPE column of the output is `LoadBalancer`, access Dremio using Flight through the address in the `EXTERNAL_IP` column and port 32010.

   For example, in the output below, the value under the `EXTERNAL-IP` column is 8.8.8.8. Therefore, you can get to the Dremio UI via port 9047 on that address: http://8.8.8.8:9047

   ```
   $ kubectl get services dremio-client
   NAME            TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                          AGE
   dremio-client   LoadBalancer   10.99.227.180   8.8.8.8           31010:32260/TCP,9047:30620/TCP   2d
   ```

   If you want to change the expose port on the load balancer, change the value of the setting `coordinator.flight.port` in the file `values.local.yaml`.
* If the value in the TYPE column of the output is `NodePort`, access Dremio using Flight through http://localhost:31357.
