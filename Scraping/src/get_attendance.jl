#!/usr/bin/env julia

@everywhere senators = collect(512:767)

@everywhere using Requests
@everywhere using Cascadia

@everywhere include("/src/scraping_functions.jl")

pmap(senators_attendance,senators)
