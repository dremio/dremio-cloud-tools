FROM gcr.io/dremio-1093/dremio-ee:24.0.0-202212051906450478-3a6c373f

USER root
ADD autoscale-handler.sh /opt/dremio/bin/autoscale-handler.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]

