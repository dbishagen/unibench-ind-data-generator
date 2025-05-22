#!/bin/bash


DATA_DIR_PATH=$1
TARGET_DIR=$2

docker run -it --rm \
--name=neo4j_import_container_tmp_1 \
--user=$(id -u):$(id -g) \
--env=NEO4J_AUTH=neo4j/neo4jpassword \
--env="NEO4J_dbms_security_procedures_unrestricted=apoc.*" \
--env="NEO4J_ACCEPT_LICENSE_AGREEMENT=yes" \
--mount type=bind,source=${DATA_DIR_PATH},target=/var/lib/neo4j/import/data \
--mount type=bind,source=$(dirname $(realpath -s $0))/data_import_scripts,target=/var/lib/neo4j/import/meta-files \
--mount type=bind,source=${TARGET_DIR},target=/data \
neo4j:5.25.1 \
bash /var/lib/neo4j/import/meta-files/import_neo4j.sh