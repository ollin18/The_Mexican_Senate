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

plot(thetime,theavg,ribbon=σ,fillalpha=.2,lab=false)
yaxis!("Iterations")
plt = twinx()
plot!(plt, dl,lab="Diameter", color=:red)
title!("Time to consensus-voter model")
xaxis!("Quarter")
savefig("/figs/voter_model.png")

plot(thetime,theavg1,ribbon=σ1,fillalpha=.2,lab="1 site")
yaxis!("Iterations")
plt = twinx()
plot!(plt, dl,lab="Diameter", color=:red)
title!("Time to consensus-Sznajd one site")
xaxis!("Quarter")
savefig("/figs/sznajd_one.png")

plot(thetime,theavg2,ribbon=σ2,fillalpha=.2,lab="2 site")
yaxis!("Iterations")
plt = twinx()
plot!(plt, dl,lab="Diameter", color=:red)
title!("Time to consensus-Sznajd two site")
xaxis!("Quarter")
savefig("/figs/sznajd_two.png")


plot(thetime,theavg,ribbon=σ,fillalpha=.2,lab=false)
yaxis!("Iterations")
plt = twinx()
plot!(plt, cl,lab="Clustering Coef.", color=:red)
title!("Time to consensus-voter model")
xaxis!("Quarter")
savefig("/figs/voter_model_cl.png")

plot(thetime,theavg1,ribbon=σ1,fillalpha=.2,lab="1 site")
yaxis!("Iterations")
plt = twinx()
plot!(plt, cl,lab="Clustering Coef.", color=:red)
title!("Time to consensus-Sznajd one site")
xaxis!("Quarter")
savefig("/figs/sznajd_one_cl.png")

plot(thetime,theavg2,ribbon=σ2,fillalpha=.2,lab="2 site")
yaxis!("Iterations")
plt = twinx()
plot!(plt, cl,lab="Clustering Coef.", color=:red)
title!("Time to consensus-Sznajd two site")
xaxis!("Quarter")
savefig("/figs/sznajd_two_cl.png")

#############
#############
#############
#############


function consensus_ws(algo)
    global avgt=Array{Any}(undef,0)
    global dl=Array{Float64}(undef,0)
    for β ∈ 0:0.01:1
        global g = watts_strogatz(128,40,β)
        global time_c=Array{Int64}(undef,0)
        gc = diameter(g)
        push!(dl,gc)
        for t in 1:100
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
    return(avgt,dl)
end

avgtws,dlws=consensus_ws(voter_model)
avgtws1,dlws1=consensus_ws(sznajd_one)
avgtws2,dlws2=consensus_ws(sznajd_two)



thetime=0:0.01:1|>collect

theavg=map(x -> x[1],avgtws) |> collect
σ=map(x->x[2],avgtws)|> collect

theavg1=map(x -> x[1],avgtws1) |> collect
σ1=map(x->x[2],avgtws1)|> collect

theavg2=map(x -> x[1],avgtws2) |> collect
σ2=map(x->x[2],avgtws2)|> collect

plot(thetime,theavg,ribbon=σ,fillalpha=.2,lab=false)
yaxis!("Iterations")
plt = twinx()
plot!(plt,thetime, dlws,lab="Diameter", color=:red)
title!("Watts-Strogatz consensus-voter model")
xaxis!("beta")
savefig("/figs/ws_voter_model.png")

plot(thetime,theavg1,ribbon=σ1,fillalpha=.2,lab="1 site")
yaxis!("Iterations")
plt = twinx()
plot!(plt, thetime,dl,lab="Diameter", color=:red)
title!("Watts-Strogatz consensus-Sznajd one site")
xaxis!("beta")
savefig("/figs/ws_sznajd_one.png")

plot(thetime,theavg2,ribbon=σ2,fillalpha=.2,lab="2 site")
yaxis!("Iterations")
plt = twinx()
plot!(plt,thetime, dl,lab="Diameter", color=:red)
title!("Watts-Strogatz consensus-Sznajd two site")
xaxis!("beta")
savefig("/figs/ws_sznajd_two.png")
