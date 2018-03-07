#!/usr/bin/env bash

export DATA=$(pwd)/data/
#export DATA=/data/

src/1_senators.sh > $DATA/senators.csv
awk 'BEGIN{FS="|"}{print$1"|"$5}' $DATA/senators.csv > $DATA/dic.csv
awk 'BEGIN{FS="|"}{print$1"|"$2}' $DATA/senators.csv > $DATA/dict.csv

src/2_attendance.sh > $DATA/attendance.csv

src/3_comissions.sh > $DATA/comissions.csv

src/4_votes.sh > $DATA/votes.csv && \
awk 'BEGIN{FS="|"}{print$2}' $DATA/votes.csv | sort -u > $DATA/edictum.csv
awk 'BEGIN {FS="|"}{print $2}' $DATA/comissions.csv | sort -u \
> $DATA/comissions_noid.csv && echo NONE >> $DATA/comissions_noid.csv

src/5_edictums.sh > $DATA/edictums.csv

sleep 120

touch $DATA/scraping.done
