#!/usr/bin/env bash
./1_senators.sh > data/senators.csv
awk 'BEGIN{FS="|"}{print$1"|"$5}' ./data/senators.csv > data/dic.csv
awk 'BEGIN{FS="|"}{print$1"|"$2}' ./data/senators.csv > data/dict.csv

./2_attendance.sh > data/attendance.csv

./3_comissions.sh > data/comissions.csv

./4_votes.sh > data/votes.csv && \
awk 'BEGIN{FS="|"}{print$2}' ./data/votes.csv | sort -u > data/edictum.csv
awk 'BEGIN {FS="|"}{print $2}' ./data/comissions.csv | sort -u \
> data/comissions_noid.csv && echo NONE >> comissions_noid.csv

./5_edictums.sh > data/edictums.csv
