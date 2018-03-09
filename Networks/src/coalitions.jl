#!/usr/bin/env julia

using OhMyREPL
using LightGraphs
include("read_graph.jl")

nombres_coaliciones = ["pri_verde","prd_pt","izquierdas","derechas","pan_izquierdas"]
directorio_data = "/data/"
directorio_clu = directorio_data*"clustering/"
directorio_ne = directorio_data*"edges/"
senadores = readdlm("/data/los_nombres.csv",',')

partidos = readdlm("/data/los_partidos.csv",',')
cuales = unique(partidos)
dic_partidos = Dict(i=>cuales[i] for i ∈ 1:6)
rev_partidos = Dict(cuales[i]=>i for i ∈ 1:6)
function a_num(party)
    rev_partidos[party]
end

partidos_num = map(a_num,partidos)

adentro = Array{Array}(0)
for partido ∈ [:pri_verde_in,:prd_pt_in,:izquierdas_in,:derechas_in,:pan_izquierdas_in]
    @eval $partido = Array{Int64}(0)
    push!(adentro,@eval $partido)
end
afuera = Array{Array}(0)
for partido ∈ [:pri_verde_out,:prd_pt_out,:izquierdas_out,:derechas_out,:pan_izquierdas_out]
    @eval $partido = Array{Int64}(0)
    push!(afuera,@eval $partido)
end
los_cluster = Array{Array}(0)
for coalicion ∈ [:pri_verde_cl,:prd_pt_cl,:izquierdas_cl,:derechas_cl,:pan_izquierdas_cl]
    @eval $coalicion = Array{Float64}(0)
    push!(los_cluster,@eval $coalicion)
end

los_partidos = Array{Array}(0)
for partido ∈ [:pri,:prd,:pan,:independiente,:pt,:pvem]
    @eval $partido = Array{Int64}(0)
    push!(los_partidos,@eval $partido)
end
for i ∈ 1:length(partidos_num)
    push!(los_partidos[partidos_num[i]],i)
end

pri_verde = vcat(los_partidos[1],los_partidos[6])
prd_pt = vcat(los_partidos[2],los_partidos[5])
izquierdas = vcat(prd_pt,los_partidos[4])
pan_izquierdas = vcat(izquierdas,los_partidos[3])
derechas = vcat(pri_verde,los_partidos[3])
coaliciones = [pri_verde,prd_pt,izquierdas,derechas,pan_izquierdas]
str_trimestre = ["primertrimestre","segundotrimestre","tercertrimestre","cuartotrimestre"]

for mes ∈ 1:23
g,no,dino = lectura(mes)
    for i ∈ 1:length(coaliciones)
        subred = induced_subgraph(g,coaliciones[i])[1]
        complemento = setdiff(collect(1:128),coaliciones[i])
        red_complemento = induced_subgraph(g,complemento)[1]
        globclus = global_clustering_coefficient(subred)
        push!(los_cluster[i],globclus)
        globne = ne(subred)
        push!(adentro[i],globne)
        push!(afuera[i],(ne(g)-globne-ne(red_complemento)))
    end
end

n=1
for partido ∈ nombres_coaliciones
    writedlm(directorio_clu*"$partido\_cc.csv",los_cluster[n],',')
    writedlm(directorio_ne*"$partido\_in.csv",adentro[n],',')
    writedlm(directorio_ne*"$partido\_out.csv",afuera[n],',')
    n += 1
end
