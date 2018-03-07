#!/usr/bin/env bash

while [ ! -e /datasc/edictums.csv ]
do
    sleep 180
done

/create_csv.sh
/create_db.sh
/var/lib/neo4j/bin/neo4j console
