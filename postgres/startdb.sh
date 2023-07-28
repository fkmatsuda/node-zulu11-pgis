#!/bin/bash
alias s4cmd='/usr/bin/s4cmd --endpoint-url=\"\$ENDPOINT_URL\" --access-key=\"\$ACCESS_KEY_ID\" --secret-key=\"\$SECRET_ACCESS_KEY\"'
mkdir $PGDATA && \
chown -R postgres:postgres $PGDATA && \
su postgres -c '/usr/lib/postgresql/15/bin/pg_ctl -D $PGDATA init' && \
mv /pg_hba.conf $PGDATA/ && \
chown postgres.postgres $PGDATA/pg_hba.conf && \
su postgres -c '/usr/lib/postgresql/15/bin/pg_ctl -D $PGDATA start' && \
su postgres -c "/usr/lib/postgresql/15/bin/psql -c \"alter user postgres with password '$DB_PASSWORD'\"" && \
su postgres -c "/usr/lib/postgresql/15/bin/psql -c \"create user $DB_USER with createdb password '$DB_PASSWORD'\"" && \
su postgres -c '/usr/lib/postgresql/15/bin/psql -d template1 -f /pginit.sql'