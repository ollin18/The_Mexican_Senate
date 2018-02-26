#! /usr/bin/env bash

procs=`grep -c ^processor /proc/cpuinfo`

julia -p $procs get_votes.jl | egrep -o "[0-9]{3}.*"

cat data/votes.csv | awk 'BEGIN{FS="|"}{print$2}' | sort -u > data/edictum.csv

cat data/comissions.csv | awk 'BEGIN {FS="|"}{print $2}' | sort -u > data/comissions_noid.csv
echo NONE >> data/comissions_noid.csv


