#!/usr/bin/env julia

@everywhere edictum = readdlm("../data/edictum.csv",Int)

@everywhere using Requests
@everywhere using Cascadia

@everywhere the_comissions = readdlm("../data/comissions_noid.csv",'|')
@everywhere the_comissions = pmap(uppercase,the_comissions)

@everywhere include("scraping_functions.jl")

pmap(giveme_edictum_with_info,edictum)
