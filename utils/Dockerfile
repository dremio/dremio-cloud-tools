FROM openjdk:8-jdk as run

ARG DOWNLOAD_URL=http://download.dremio.com/community-server/4.2.2-202004211133290458-b550b6fa/dremio-community-4.2.2-202004211133290458-b550b6fa.tar.gz

RUN \
  mkdir -p /opt/dremio \
  && mkdir -p /var/lib/dremio \
  && mkdir -p /var/run/dremio \
  && mkdir -p /var/log/dremio \
  && mkdir -p /opt/dremio/data \
  && groupadd --system dremio \
  && useradd --base-dir /var/lib/dremio --system --gid dremio dremio \
  && chown -R dremio:dremio /opt/dremio/data \
  && chown -R dremio:dremio /var/run/dremio \
  && chown -R dremio:dremio /var/log/dremio \
  && chown -R dremio:dremio /var/lib/dremio \
  && wget -q "${DOWNLOAD_URL}" -O dremio.tar.gz \
  && tar vxfz dremio.tar.gz -C /opt/dremio --strip-components=1 \
  && wget http://apache.osuosl.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip  \
  && unzip apache-maven-3.6.3-bin.zip -d /opt/dremio \
  && git clone https://github.com/dremiojonny/dremio-prometheus-exporter.git && cd dremio-prometheus-exporter \
  && export PATH=$PATH:/opt/dremio/apache-maven-3.6.3/bin \
  && mvn clean install && chown dremio target/dremio-telemetry-prometheus-*-shaded.jar \
  && mv target/dremio-telemetry-prometheus-*-shaded.jar /opt/dremio/jars \
  && rm -rf ~/.m2 && rm -rf /opt/dremio/apache-maven-3.6.3 \
  && rm -rf apache-maven-3.6.3-bin.zip \
  && rm -rf dremio.tar.gz

USER dremio
WORKDIR /opt/dremio
ENV DREMIO_HOME /opt/dremio
ENV DREMIO_PID_DIR /var/run/dremio
ENV DREMIO_GC_LOGS_ENABLED="no"
ENV DREMIO_LOG_DIR="/var/log/dremio"
ENV SERVER_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps"
ENTRYPOINT ["bin/dremio", "start-fg"]
