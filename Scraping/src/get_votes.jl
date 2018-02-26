#!/usr/bin/env julia

@everywhere senators = collect(512:767)

@everywhere using Requests
@everywhere using Cascadia

@everywhere include("scraping_functions.jl")

pmap(senators_votes,senators)
