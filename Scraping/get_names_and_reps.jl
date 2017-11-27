#!/usr/bin/env julia

@everywhere alternates = 640:767

@everywhere using Requests
@everywhere using Cascadia

@everywhere include("scraping_functions.jl")

pmap(senators_and_alternates,alternates)
