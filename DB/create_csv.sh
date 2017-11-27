#! /usr/bin/env bash

cat ../scraping/data/senators.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|"$3"|"$4"|"$6"|"$7}' > ./nodes/list/senators.csv

cp ../scraping/data/comissions_noid.csv ./nodes/list/comissions.csv

cat ../scraping/data/attendance.csv | awk 'BEGIN{FS="|"}{print$2}' | sort -u > ./nodes/list/day_tmp.csv
cat ../scraping/data/edictums.csv | awk 'BEGIN{FS="|"}{print$4}' | sort -u >> ./nodes/list/day_tmp.csv
sort -u ./nodes/list/day_tmp.csv > ./nodes/list/day.csv
rm ./nodes/list/day_tmp.csv

cp ../scraping/data/edictum.csv ./nodes/list/edictum.csv

cp ../scraping/data/comissions.csv ./edges/list/comissions.csv

cat ../scraping/data/attendance.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|"$4"|ATTENDED"}' > ./edges/list/attendance.csv

awk 'BEGIN {FS="|"}{OFS="|"}{$4="VOTE";print}' ../scraping/data/votes.csv > ./edges/list/votes.csv

cat ../scraping/data/edictums.csv | awk 'BEGIN{FS="|"}{print$1"|"$2"|PROPOSED"}' > ./edges/list/edictums.csv

cat ../scraping/data/edictums.csv | awk 'BEGIN{FS="|"}{print$1"|"$3}' | sort -u > ./nodes/list/edictums.csv

cat ../scraping/data/edictums.csv | awk 'BEGIN{FS="|"}{print$4"|"$1"|WAS_VOTED"}' | sort -u > ./edges/list/edictums_day.csv
