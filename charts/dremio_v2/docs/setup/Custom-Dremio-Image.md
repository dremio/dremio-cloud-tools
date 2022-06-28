# Custom Dremio Image

You may occasionally need to customize Dremio by adding an additional [Dremio ARP connector](https://www.dremio.com/hub/) or other JAR(s). The recommended approach is to create a new container image for Dremio containing the customization.

### Prerequisites
* Local machine with Docker installed
* Private container image repository accessible by your Kubernetes cluster

To create a custom container image, create a new directory containing the additional JAR(s) that you wish to add along with a `Dockerfile` with the following contents:

```dockerfile
FROM dremio/dremio-oss:15.0.0
USER root

# To copy multiple files, change the below two lines to the following:
# COPY <some-file-1> <some-file-2> /opt/dremio/jars/
# RUN chown 1000:1000 /opt/dremio/jars/<some-file-1> /opt/dremio/jars/<some-file-2>
COPY <some-file-here> /opt/dremio/jars/
RUN chown 1000:1000 /opt/dremio/jars/<some-file-here>

# For Dremio ARP connectors, you may need to copy file(s) to /opt/dremio/jars/3rdparty/ as well. Uncomment the following lines as appropriate:
#
# (1) For a single file, uncomment the below two lines.
# COPY <some-file-here> /opt/dremio/jars/3rdparty/
# RUN chown 1000:1000 /opt/dremio/jars/3rdparty/<some-file-here>
#
# (2) Or, to copy multiple files, uncomment the below two lines.
# COPY <some-file-1> <some-file-2> /opt/dremio/jars/3rdparty/
# RUN chown 1000:1000 /opt/dremio/jars/3rdparty/<some-file-1> /opt/dremio/jars/3rdparty/<some-file-2>

USER dremio
```

Ensure that you have set the desired base image tag (i.e., `dremio/dremio-oss:15.0.0`) and replaced the name(s) of the desired file(s) to add. To create the image, from within the folder with the `Dockerfile`, invoke the following commands:

```bash
docker build . -t <private-container-registry>/<custom-image-name>:<custom-version-tag>
docker push <private-container-repository>/<custom-image-name>:<custom-version-tag>
```

Once you have your new container image built and pushed, update your `values.local.yaml` file to set the `image` and `imageTag` values as appropriate.