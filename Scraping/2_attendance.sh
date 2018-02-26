#! /usr/bin/env bash

cat data/senators.csv | awk 'BEGIN{FS="|"}{print$1"|"$6}' > data/dict.csv

procs=`grep -c ^processor /proc/cpuinfo`

julia -p $procs get_attendance.jl | egrep -o "[0-9]{3}.*"
