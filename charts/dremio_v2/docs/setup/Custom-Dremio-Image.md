# Custom Dremio Image

You may occasionally need to customize Dremio by adding an additional Dremio connector or other JAR. The recommended approach is to create a new container image for Dremio containing the customization.

Prerequisites:
* Local machine with Docker installed
* Private container image repository accessible by your Kubernetes cluster

To create a custom container image, create a new directory containing the additonal JAR(s) that you wish to add along with a `Dockerfile` with the following contents:

```dockerfile
FROM dremio/dremio-oss:15.0.0
USER root

# To copy multiple files, change the below two lines to the following:
# COPY <some-file-1> <some-file-2> /opt/dremio/jars/3rdparty/
# RUN chown 1000:1000 /opt/dremio/jars/3rdparty/<some-file-1> /opt/dremio/jars/3rdparty/<some-file-2>
COPY <some-file-here> /opt/dremio/jars/3rdparty/
RUN chown 1000:1000 /opt/dremio/jars/3rdparty/<some-file-here>

USER dremio
```

Ensure that you have set the desired base image tag (i.e., `dremio/dremio-oss:15.0.0`) and to replace the name of the desired file to add. Then to create the image, from within the directory you created with the Dockerfile and additional JAR present, invoke the following commands:

```bash
docker build . -t <private-container-registry>/<custom-image-name>:<custom-version-tag>
docker push <private-container-repository>/<custom-image-name>:<custom-version-tag>
```

Once you have your new container image built and pushed, update your `values.local.yaml` file to set the `image` and `imageTag` values as appropriate.