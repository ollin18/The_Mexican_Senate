#!/usr/bin/env bash

while [ ! -e /datasc/scraping.done ]
do
    sleep 180
done

/create_csv.sh
/create_db.sh
/var/lib/neo4j/bin/neo4j console
