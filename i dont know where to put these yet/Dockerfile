FROM gcr.io/dremio-1093/dremio-ee:24.0.0-202212051906450478-3a6c373f

ADD aclHandler.sh /opt/dremio/bin

USER dremio

ENV DREMIO_URL=http://34.127.33.200:9047
ENV DREMIO_USER=brian.ngo
ENV DREMIO_PASSWORD=Test!1234
ENV PROMETHEUS_ENDPOINT=http://prometheus.dev.drem.io

# ENTRYPOINT ["tail", "-f", "/dev/null"]
