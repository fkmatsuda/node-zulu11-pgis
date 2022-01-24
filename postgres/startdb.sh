#!/bin/bash
mkdir $PGDATA && \
chown -R postgres:postgres $PGDATA && \
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA init' && \
mv /pg_hba.conf $PGDATA/ && \
chown postgres.postgres $PGDATA/pg_hba.conf && \
su postgres -c '/usr/lib/postgresql/13/bin/pg_ctl -D $PGDATA start' && \    
su postgres -c '/usr/lib/postgresql/13/bin/psql -d template1 -f /pginit.sql'