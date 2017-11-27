#!/usr/bin/env julia

@everywhere alternates = 640:767

@everywhere using Requests
@everywhere using Cascadia

@everywhere include("scraping_functions.jl")

pmap(id_and_comissions,alternates)
