#! /usr/bin/env bash

export NODEH=./nodes/headers
export NODEL=./nodes/list
export EDGEH=./edges/headers
export EDGEL=./edges/list

/var/lib/neo4j/bin/neo4j-admin import --mode=csv --delimiter="|" \
	--ignore-duplicate-nodes=true \
        --database=senate.db \
	--nodes:Senator "$NODEH/senators.csv,$NODEL/senators.csv" \
	--nodes:comission "$NODEH/comissions.csv,$NODEL/comissions.csv"\
	--nodes:day "$NODEH/day.csv,$NODEL/day.csv" \
	--nodes:edictum "$NODEH/edictums.csv,$NODEL/edictums.csv" \
	--relationships "$EDGEH/comissions.csv,$EDGEL/comissions.csv" \
	--relationships "$EDGEH/attendance.csv,$EDGEL/attendance.csv" \
	--relationships "$EDGEH/votes.csv,$EDGEL/votes.csv" \
	--relationships "$EDGEH/edictums.csv,$EDGEL/edictums.csv" \
	--relationships "$EDGEH/edictums_day.csv,$EDGEL/edictums_day.csv"

