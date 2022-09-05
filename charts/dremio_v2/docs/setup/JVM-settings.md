# JVM settings

In order to implement any specific JVM settings, the configuration needs to be added in the `values.yaml`

Special attention should be paid to how much memory is set in the `values.yaml` when changing heap sizes since by default the Dremio pod will allocated a fixed size to the heap and remaining to direct memory. If you alter your heap settings then you need to also explicitly declare your direct memory settings to avoid over-subscribing the pod.

Once these values are configured, to update the configuration used in the pods, run the Helm upgrade command:

```bash
$ helm upgrade <release-name> dremio_v2 -f values.local.yaml
```

## Example

Here is a useful example setting up the JVM on a coordinator, note how the Heap ( `Xms` and `Xmx` ) are set along with `-XX:MaxDirectMemorySize`

```
coordinator:
...
  # Uncomment the lines below to use a custom set of extra startup parameters for the coordinator.
  extraStartParams: >-
     -Ddremio.log.path=/opt/dremio/data
     -Xloggc:/opt/dremio/data/gc.log
     -XX:+UseGCLogFileRotation
     -XX:NumberOfGCLogFiles=5
     -XX:GCLogFileSize=4000k
     -XX:+PrintGCDetails
     -XX:+PrintGCTimeStamps
     -XX:+PrintGCDateStamps
     -XX:+PrintClassHistogramBeforeFullGC
     -XX:+PrintClassHistogramAfterFullGC
     -XX:+HeapDumpOnOutOfMemoryError
     -XX:HeapDumpPath=/opt/dremio/data/
     -XX:+UseG1GC
     -XX:G1HeapRegionSize=32M
     -XX:MaxGCPauseMillis=500
     -XX:InitiatingHeapOccupancyPercent=25
     -XX:ErrorFile=/opt/dremio/data/hs_err_pid%p.log
     -XX:+DisableExplicitGC
     -Xms31G
     -Xmx31G
     -XX:MaxDirectMemorySize=10G
```
