#! /usr/bin/env bash

export DATA=/datasc/
export NODEH=/nodes/headers
export EDGEH=/edges/headers
export NODEL=/nodes/list
export EDGEL=/edges/list

cat $DATA/senators.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|"$3"|"$4"|"$5"|"$6}' > $NODEL/senators.csv

cp $DATA/comissions_noid.csv $NODEL/comissions.csv

cat $DATA/attendance.csv | awk 'BEGIN{FS="|"}{print$2}' | sort -u > $NODEL/day_tmp.csv
cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$4}' | sort -u >> $NODEL/day_tmp.csv
sort -u $NODEL/day_tmp.csv > $NODEL/day.csv
rm $NODEL/day_tmp.csv

cp $DATA/edictum.csv $NODEL/edictum.csv

cp $DATA/comissions.csv $EDGEL/comissions.csv

cat $DATA/attendance.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|"$4"|ATTENDED"}' | sed 's/Ó/O/g' > $EDGEL/attendance.csv

awk 'BEGIN {FS="|"}{OFS="|"}{$4="VOTE";print}' $DATA/votes.csv > $EDGEL/votes.csv

cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|PROPOSED"}' > $EDGEL/edictums.csv

cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$1"|"$3}' | sort -u > $NODEL/edictums.csv

cat $DATA/edictums.csv | awk 'BEGIN{FS="|"}{print$4"|"$1"|WAS_VOTED"}' | sort -u > $EDGEL/edictums_day.csv

echo "edictumId:ID|information" > $NODEH/edictums.csv
echo "comission:ID" > $NODEH/comissions.csv
echo "day:ID" > $NODEH/day.csv
echo "tit_id:ID|senator|party|entity|id_alt|alternate" > $NODEH/senators.csv
echo ":START_ID|:END_ID|attendancy|:TYPE" > $EDGEH/attendance.csv
echo ":START_ID|:END_ID|:TYPE" > $EDGEH/comissions.csv
echo ":END_ID|:START_ID|:TYPE" > $EDGEH/edictums.csv
echo ":START_ID|:END_ID|:TYPE" > $EDGEH/edictums_day.csv
echo ":START_ID|:END_ID|voted|:TYPE" > $EDGEH/votes.csv
