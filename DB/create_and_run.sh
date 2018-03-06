#!/usr/bin/env bash

while [ ! -e /edges/list/edictums.csv ]
do
    sleep 180
done

/create_db.sh
/var/lib/neo4j/bin/neo4j console
