#!/bin/bash


#MONGODB_VERSION=mongo:4.4.29-focal
MONGODB_VERSION=mongo:8.0.0-rc11-jammy

DATA_DIR_PATH=$1
TARGET_DIR=$2

docker run --rm -d \
--name=mongo_import_container_tmp_1 \
--user=$(id -u):$(id -g) \
--mount type=bind,source=${DATA_DIR_PATH},target=/import \
--mount type=bind,source=$(dirname $(realpath -s $0))/data_import_scripts,target=/import_scripts \
--mount type=bind,source=${TARGET_DIR},target=/data/db \
${MONGODB_VERSION}

sleep 30

docker exec -it mongo_import_container_tmp_1 \
bash /import_scripts/import_mongodb.sh

docker stop mongo_import_container_tmp_1
