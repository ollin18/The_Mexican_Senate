#! /usr/bin/env bash

procs=`grep -c ^processor /proc/cpuinfo`

julia -p $procs src/get_comissions.jl | egrep -o "[0-9]{3}.*"
