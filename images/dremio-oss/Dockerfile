#
# Copyright (C) 2017 Dremio Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Build Image.
FROM maven:3.5.3-jdk-8 as builder
RUN mkdir /src \
    && echo "35.190.5.79 maven.dremio.com" >> /etc/hosts \
    && git clone https://github.com/dremio/dremio-oss.git /src/dremio-oss \
    && mvn -B install -f /src/dremio-oss/pom.xml install -DskipTests

# Run Image
FROM openjdk:8-jdk as run

MAINTAINER Dremio

LABEL org.label-schema.name='dremio/dremio-oss'
LABEL org.label-schema.description='Dremio OSS.'

COPY --from=builder  /src/dremio-oss/distribution/server/target/dremio-community-*.tar.gz .
RUN  mkdir -p /opt/dremio \
  && mkdir -p /var/lib/dremio \
  && mkdir -p /var/run/dremio \
  && mkdir -p /var/log/dremio \
  && mkdir -p /opt/dremio/data \
  \
  && groupadd --system dremio \ 
  && useradd --base-dir /var/lib/dremio --system --gid dremio dremio \
  && chown -R dremio:dremio /opt/dremio/data \
  && chown -R dremio:dremio /var/run/dremio \
  && chown -R dremio:dremio /var/log/dremio \
  && chown -R dremio:dremio /var/lib/dremio \
  && tar vxfz dremio-community-*.tar.gz -C /opt/dremio --strip-components=1 \
  && rm -rf dremio-community-*.tar.gz

COPY logback.xml /opt/dremio/conf/
COPY dremio /opt/dremio/bin/
COPY logback-access.xml /opt/dremio/conf/

EXPOSE 9047/tcp
EXPOSE 31010/tcp

USER dremio
WORKDIR /opt/dremio
ENV DREMIO_HOME /opt/dremio
ENV DREMIO_GC_LOGS_ENABLED="no"
ENV SERVER_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps"
ENTRYPOINT ["bin/dremio", "start-fg"]
