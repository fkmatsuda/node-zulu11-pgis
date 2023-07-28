FROM node:lts-bookworm-slim
ENV DOWNLOAD_URL=https://cdn.azul.com/zulu/bin/zulu11.66.15-ca-jdk11.0.20-linux_amd64.deb
ENV ZULU_DEB=zulu11.66.15-ca-jdk11.0.20-linux_amd64.deb
ENV MVN_PREFIX=apache-maven-3.9.3
ENV MVN_TAR=$MVN_PREFIX-bin.tar.gz
ENV DOWNLOAD_MVN=https://dlcdn.apache.org/maven/maven-3/3.9.3/binaries/$MVN_TAR
ENV JAVA_PATH=/usr/lib/jvm/zulu-11-amd64
ENV PGDATA=/database
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_USER=qgis
ENV DB_PASSWORD=qgis
ENV ENDPOINT_URL=https://s3.amazonaws.com
ENV ACCESS_KEY_ID=access
ENV SECRET_ACCESS_KEY=secret
RUN apt-get update -qq && \
    apt-get install -qq git wget && \
    eval $(ssh-agent -s) && \
    wget $DOWNLOAD_URL && \
    apt-get install -y java-common libasound2 libxi6 libxtst6 apt-utils p7zip-full libfontconfig1 libxrender1 gnupg2 lsb-release s4cmd openssh-client git && \
    dpkg -i $ZULU_DEB && \
    mkdir /opt/maven && \
    wget $DOWNLOAD_MVN && \
    tar -C /opt/maven/ -xzvf ./$MVN_TAR && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -  && \
    apt-get update && \
    apt-get -y install postgresql-15 postgresql-15-postgis-3 postgresql-15-postgis-3-scripts && \
    apt-get autoclean && \
    rm ./$MVN_TAR && \
    rm $ZULU_DEB && \
    ln -s $JAVA_PATH /usr/lib/jvm/zulu-11

COPY postgres/pg_hba.conf /pg_hba.conf
COPY postgres/pginit.sql /pginit.sql
COPY postgres/startdb.sh /startdb.sh

ENV MAVEN_HOME="/opt/maven/$MVN_PREFIX"
ENV JAVA_HOME="/usr/lib/jvm/zulu-11"
ENV PATH="$JAVA_HOME/bin:$PATH:$MAVEN_HOME/bin"
