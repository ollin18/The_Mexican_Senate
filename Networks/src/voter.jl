#!/usr/bin/env julia

using OhMyREPL
using LightGraphs
using StatsBase
using DelimitedFiles
using Plots
gr()
include("/src/read_graph.jl")
include("/src/utils.jl")

let
    global cl=Array{Float64}(undef,0)
    for mes ∈ 1:20
        global g,no,dino = lectura(mes)
        gc = mglobal_clustering_coefficient(g)
        push!(cl,gc)
    end
end

let
    global dl=Array{Float64}(undef,0)
    for mes ∈ 1:20
        global g,no,dino = lectura(mes)
        if length(connected_components(g))==1
            gc = diameter(g)
            push!(dl,gc)
        else
            global g1 = induced_subgraph(g,connected_components(g)[1])[1]
            gc = diameter(g1)
            push!(dl,gc)
        end
    end
end

function consensus(algo)
    global avgt=Array{Any}(undef,0)
    for mes ∈ 1:20
        global g,no,dino = lectura(mes)
        global time_c=Array{Int64}(undef,0)
        for t in 1:1000
            if length(connected_components(g))==1
                the_time = algo(g)
            else
                global largest = 0
                for i in 1:length(connected_components(g))
                    global g1 = induced_subgraph(g,connected_components(g)[i])[1]
                    if nv(g1) > 3
                        result = algo(g1)
                        if length(result)>largest
                            largest=result
                        end
                        the_time = largest
                    end
                end
            end
            push!(time_c,the_time)
        end
        ms = mean_and_std(time_c)
        push!(avgt,ms)
    end
    avgt
end

avgt=consensus(voter_model)
avgt1=consensus(sznajd_one)
avgt2=consensus(sznajd_two)
cl

thetime=1:1:20|>collect

theavg=map(x -> x[1],avgt) |> collect
σ=map(x->x[2],avgt)|> collect

theavg1=map(x -> x[1],avgt1) |> collect
σ1=map(x->x[2],avgt1)|> collect

theavg2=map(x -> x[1],avgt2) |> collect
σ2=map(x->x[2],avgt2)|> collect

plot(thetime,theavg,ribbon=σ,fillalpha=.2,lab="voter model")
plot(thetime,theavg1,ribbon=σ1,fillalpha=.2,lab="1 site")
plot(thetime,theavg2,ribbon=σ2,fillalpha=.2,lab="2 site")
plt = twinx()
plot!(plt, cl, color=:red)
plot!(plt, dl,lab="Diameter", color=:red)
title!("Time to consensus")
savefig("/figs/prueba.png")
savefig("/figs/voter.png")

#  plot!(x,wings,lab="Modularity (PRI/PVEM-PAN/Left)",c=:olive)


