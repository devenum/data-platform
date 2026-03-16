#!/bin/bash

# postgres
su - postgres -c "/usr/lib/postgresql/13/bin/initdb -D /postgresql"
su - postgres -c "/usr/lib/postgresql/13/bin/pg_ctl -D /postgresql start"
sleep 5
psql -U postgres -c "CREATE USER admin WITH PASSWORD 'admin123';"
psql -U postgres -c "CREATE DATABASE metadata OWNER admin;"
psql -U postgres -c "CREATE DATABASE airflow OWNER admin;"
psql -U postgres -c "CREATE DATABASE superset OWNER admin;"
psql -U postgres -c "CREATE DATABASE data OWNER admin;"
psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"
su -postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /postgresql stop"
supervisorctl start postgres

# Airflow
export AIRFLOW_HOME=/root/airflow
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://postgres:postgres@localhost:5432/airflow"
export AIRFLOW__CORE__EXECUTOR="LocalExecutor"
airflow db init
airflow users create \
  --username admin \
  --password admin \
  --firstname admin \
  --lastname admin \
  --role Admin \
  --email admin@admin.com

#!/bin/bash
mongosh --eval "rs.initiate({
  _id: 'rs0',
  members: [{ _id: 0, host: 'localhost:27017' }]
})"
mongosh --eval "rs.secondaryOk()"
