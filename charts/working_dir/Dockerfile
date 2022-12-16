FROM gcr.io/dremio-1093/dremio-ee:24.0.0-202212051906450478-3a6c373f

ADD aclHandler.sh /opt/dremio/bin

USER dremio

ENV DREMIO_URL=url
ENV DREMIO_USER=user
ENV DREMIO_PASSWORD=password
ENV PROMETHEUS_ENDPOINT=endpoint

# ENTRYPOINT ["tail", "-f", "/dev/null"]
