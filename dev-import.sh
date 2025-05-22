#!/bin/bash

## Neo4j
printf "Importing data into Neo4j...\n"
cat data-generator/scripts/data_import_scripts/import_neo4j.cypher | \
docker compose exec -T neo4j cypher-shell -u neo4j -p neo4jpassword -d neo4j

## MongoDB
printf "Importing data into MongoDB...\n"
docker compose exec mongodb bash -c 'mongoimport --drop --db unibench --collection Order --jsonArray /import/order.json'

## Postgres
printf "Importing data into Postgres...\n"
cat data-generator/scripts/data_import_scripts/import_postgres.sql | \
docker compose exec -T postgres psql -U postgres  
