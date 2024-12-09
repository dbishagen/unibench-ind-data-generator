#!/bin/bash



DATA_DIR_PATH=$1
TARGET_DIR=$2

docker run --rm -d \
--name=postgres_import_container_tmp_1 \
--user=$(id -u):$(id -g) \
--env POSTGRES_PASSWORD=root \
--mount type=bind,source=${DATA_DIR_PATH},target=/import \
--mount type=bind,source=$(dirname $(realpath -s $0))/data_import_scripts,target=/import_scripts \
--mount type=bind,source=${TARGET_DIR},target=/var/lib/postgresql/data \
postgres:17.1 

sleep 30

docker exec -it postgres_import_container_tmp_1 \
bash -c 'psql -U postgres -f /import_scripts/import_postgres.sql'

docker stop postgres_import_container_tmp_1

