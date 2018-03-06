#! /usr/bin/env bash

export DATA=/datasc/
export NODEL=./nodes/list
export EDGEL=./edges/list

cat $DATA/senators.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|"$3"|"$4"|"$6"|"$7}' > $NODEL/senators.csv

cp $DATA/comissions_noid.csv $NODEL/comissions.csv

cat $DATA/attendance.csv | awk 'BEGIN{FS="|"}{print$2}' | sort -u > $NODEL/day_tmp.csv
cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$4}' | sort -u >> $NODEL/day_tmp.csv
sort -u $NODEL/day_tmp.csv > $NODEL/day.csv
rm $NODEL/day_tmp.csv

cp $DATA/edictum.csv $NODEL/edictum.csv

cp $DATA/comissions.csv $EDGEL/comissions.csv

cat $DATA/attendance.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|"$4"|ATTENDED"}' > $EDGEL/attendance.csv

awk 'BEGIN {FS="|"}{OFS="|"}{$4="VOTE";print}' $DATA/votes.csv > $EDGEL/votes.csv

cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|PROPOSED"}' > $EDGEL/edictums.csv

cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$1"|"$3}' | sort -u > $NODEL/edictums.csv

cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$4"|"$1"|WAS_VOTED"}' | sort -u > $EDGEL/edictums_day.csv
