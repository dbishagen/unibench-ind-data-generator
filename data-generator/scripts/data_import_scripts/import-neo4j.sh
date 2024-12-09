#!/bin/bash

neo4j-admin database import full neo4j \
--overwrite-destination=true \
--verbose=true \
--delimiter="," \
--id-type=integer \
--nodes=Person=import/meta-files/person-header.csv,import/data/customer.csv \
--nodes=Post=import/meta-files/post-header.csv,import/data/post.csv \
--nodes=Tag=import/meta-files/tag-header.csv,import/data/tag.csv \
--nodes=Feedback=import/meta-files/feedback-header.csv,import/data/feedback.csv \
--relationships=HAS_INTEREST=import/meta-files/HAS_INTEREST-header.csv,import/data/HAS_INTEREST.csv \
--relationships=WROTE=import/meta-files/WROTE-header.csv,import/data/WROTE.csv \
--relationships=HAS_TAG=import/meta-files/HAS_TAG-header.csv,import/data/HAS_TAG.csv \
--relationships=HAS_CREATED=import/meta-files/HAS_CREATED-header.csv,import/data/HAS_CREATED.csv
