#!/usr/bin/env bash

#./create_csv.sh
#./create_db.sh

docker build --tag senate_neo:0.1 --tag senate_neo:latest .

docker run \
    --publish=7474:7474 --publish=7473:7473 \
    --volume=$HOME/data:/data \
    --volume=$HOME/neo4j/logs:/logs \
    --env=NEO4J_AUTH=none \
    --env=NEO4J_dbms_active_database="senate.db" \
    senate_neo
