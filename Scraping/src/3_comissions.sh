#! /usr/bin/env bash

procs=`grep -c ^processor /proc/cpuinfo`

julia -p $procs get_comissions.jl | egrep -o "[0-9]{3}.*"
