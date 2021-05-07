# Custom Dremio Image

In some cases, you may wish to customize Dremio by adding an additional connector or other JAR. The recommended approach is to create a new container image to Dremio containing the customization.

Prerequisites:
* Local machine with Docker installed
* Private container image repository accessible by your Kubernetes cluster

To create a custom container image, create a new directory containing the additonal JAR that you wish to add along with a `Dockerfile` with the below contents.

```dockerfile
FROM dremio/dremio-oss:15.0.0
USER root
COPY <some-file-here> /opt/dremio/jars/3rdparty/
RUN chown 1000:1000 /opt/dremio/jars/3rdparty/<some-file-here>
USER dremio
```

Ensure that you have set the desired base image tag (i.e., `dremio/dremio-oss:15.0.0`) in this process along with replacing the name of the desired file to add. Then to create the image, first ensure that you are in the directory created with the Dockerfile and additional JAR present. Once you are in the directory, invoke the following commands:

```bash
docker build . -t <private-container-registry>/<custom-image-name>:<custom-version>
docker push <private-container-repository>/<custom-image-name>:<custom-version>
```

Once you have your new container image built and pushed, update your `values.local.yaml` file to set the `image` and `imageTag` values as appropriate.