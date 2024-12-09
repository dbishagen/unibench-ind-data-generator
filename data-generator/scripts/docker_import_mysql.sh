#!/bin/bash



DATA_DIR_PATH=$1
TARGET_DIR=$2

docker run --rm -d \
--name=mysql_import_container_tmp_1 \
--user=$(id -u):$(id -g) \
--env MYSQL_ROOT_PASSWORD=root \
--mount type=bind,source=${DATA_DIR_PATH},target=/import \
--mount type=bind,source=$(dirname $(realpath -s $0))/data_import_scripts,target=/import_scripts \
--mount type=bind,source=${TARGET_DIR},target=/var/lib/mysql \
mysql:9.1.0 \
--secure-file-priv=/import

sleep 30

docker exec -it mysql_import_container_tmp_1 \
bash -c 'mysql -u root -proot < /import_scripts/import_mysql.sql'

docker stop mysql_import_container_tmp_1

