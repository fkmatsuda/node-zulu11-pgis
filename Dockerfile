FROM node:17.4-bullseye-slim
ARG TARGETPLATFORM
ENV DOWNLOAD_URL=invalid
ENV ZULU_DEB=invalid
ENV PGDATA=/database
RUN case "${TARGETPLATFORM}" in \
         "linux/amd64")     DOWNLOAD_URL=https://cdn.azul.com/zulu/bin/zulu11.54.23-ca-jdk11.0.14-linux_amd64.deb               \
                            ZULU_DEB="zulu11.54.23-ca-jdk11.0.14-linux_amd64.deb"        ;; \
         "linux/arm64")     DOWNLOAD_URL=https://cdn.azul.com/zulu-embedded/bin/zulu11.54.23-ca-jdk11.0.14-linux_arm64.deb           \
                            ZULU_DEB="zulu11.54.23-ca-jdk11.0.14-linux_arm64.deb"    ;; \
    esac && \
    apt-get update -qq && \
    apt-get install -qq git wget && \
    eval $(ssh-agent -s) && \
    wget $DOWNLOAD_URL && \
    apt-get install -y java-common libasound2 libxi6 libxtst6 apt-utils p7zip-full libfontconfig1 libxrender1 gnupg2 lsb-release && \
    dpkg -i $ZULU_DEB && \
    mkdir /opt/maven && \
    wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz && \
    tar -C /opt/maven/ -xzvf ./apache-maven-3.8.4-bin.tar.gz && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -  && \
    apt-get update && \
    apt-get -y install postgresql-13 postgresql-13-postgis-3 postgresql-13-postgis-3-scripts && \
    apt-get autoclean && \
    rm ./apache-maven-3.8.4-bin.tar.gz && \
    rm $ZULU_DEB

COPY postgres/pg_hba.conf /pg_hba.conf
COPY postgres/pginit.sql /pginit.sql

RUN mkdir $PGDATA && \
    chown -R postgres:postgres $PGDATA && \
    su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA init' && \
    mv /pg_hba.conf $PGDATA/ && \
    chown postgres.postgres $PGDATA/pg_hba.conf && \
    su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA start' && \    
    su postgres -c '/usr/lib/postgresql/13/bin/psql -d template1 -f /pginit.sql' && \
    su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA stop'  


ENV MAVEN_HOME="/opt/maven/apache-maven-3.8.4"
ENV JAVA_HOME="/usr/lib/jvm/zulu-11"
ENV PATH="$JAVA_HOME/bin:$PATH:$MAVEN_HOME/bin"
