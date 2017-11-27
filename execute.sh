#!/usr/bin/env bash
./Scraping/execute.sh
./DB/execute.sh
julia Networks/src/party_color.jl
julia Networks/src/communities_langle.jl
julia Networks/src/coalitions.jl
julia Networks/src/in_and_out.jl
julia Networks/src/cc_plot.jl
