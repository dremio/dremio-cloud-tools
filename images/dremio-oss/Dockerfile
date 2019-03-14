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

FROM openjdk:8-jdk as run

MAINTAINER Dremio

LABEL org.label-schema.name='dremio/dremio-oss'
LABEL org.label-schema.description='Dremio OSS.'

ARG  DOWNLOAD_URL=https://download.dremio.com/community-server/3.0.1-201811132128360291-804fe82/dremio-community-3.0.1-201811132128360291-804fe82.tar.gz
RUN  echo "${DOWNLOAD_URL}"
RUN  mkdir -p /opt/dremio
RUN  mkdir -p /var/lib/dremio
RUN  mkdir -p /var/run/dremio
RUN  mkdir -p /var/log/dremio
RUN  mkdir -p /opt/dremio/data
RUN  groupadd --system dremio
RUN  useradd --base-dir /var/lib/dremio --system --gid dremio dremio
RUN  chown -R dremio:dremio /opt/dremio/data
RUN  chown -R dremio:dremio /var/run/dremio
RUN  chown -R dremio:dremio /var/log/dremio
RUN  chown -R dremio:dremio /var/lib/dremio
RUN  wget -q "${DOWNLOAD_URL}" -O dremio.tar.gz
RUN  tar vxfz dremio.tar.gz -C /opt/dremio --strip-components=1
RUN  rm -rf dremio.tar.gz

EXPOSE 9047/tcp
EXPOSE 31010/tcp
EXPOSE 45678/tcp

USER dremio
WORKDIR /opt/dremio
ENV DREMIO_HOME /opt/dremio
ENV DREMIO_PID_DIR /var/run/dremio
ENV DREMIO_GC_LOGS_ENABLED="no"
ENV DREMIO_LOG_DIR="/var/log/dremio"
ENV SERVER_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps"
ENTRYPOINT ["bin/dremio", "start-fg"]
