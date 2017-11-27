using OhMyREPL
using RCall
using LightGraphs
using GraphPlot
using Colors
using Compose
using GraphIO
include("utils.jl")

global_clustering = Array{Float64}(0)
los_cluster = Array{Array}(0)
for partido ∈ [:pri_clus,:prd_clus,:pan_clus,:independiente_clus,:pt_clus,:pvem_clus]
    @eval $partido = Array{Float64}(0)
    push!(los_cluster,@eval $partido)
end
global_ne = Array{Float64}(0)
los_ne = Array{Array}(0)
for partido ∈ [:pri_ne,:prd_ne,:pan_ne,:independiente_ne,:pt_ne,:pvem_ne]
    @eval $partido = Array{Int64}(0)
    push!(los_ne,@eval $partido)
end
afuera = Array{Array}(0)
for partido ∈ [:pri_out,:prd_out,:pan_out,:independiente_out,:pt_out,:pvem_out]
    @eval $partido = Array{Int64}(0)
    push!(afuera,@eval $partido)
end
avgk = Array{Float64}(0)
maxk = Array{Float64}(0)

nombres_partidos = ["pri","prd","pan","independiente","pt","pvem"]
directorio_data = "../data/"
directorio_adj = directorio_data*"adj/"
directorio_clu = directorio_data*"clustering/"
directorio_ne = directorio_data*"edges/"
directorio_k = directorio_data*"k/"
directorio_maxk = directorio_data*"maxk/"
directorio_fig = "../figs/"
isdir(directorio_data) || mkdir(directorio_data)
isdir(directorio_adj) || mkdir(directorio_adj)
isdir(directorio_adj*"treshold/") || mkdir(directorio_adj*"treshold/")
isdir(directorio_adj*"weighted/") || mkdir(directorio_adj*"weighted/")
isdir(directorio_clu) || mkdir(directorio_clu)
isdir(directorio_ne) || mkdir(directorio_ne)
isdir(directorio_fig) || mkdir(directorio_fig)
isdir(directorio_k) || mkdir(directorio_k)
isdir(directorio_maxk) || mkdir(directorio_maxk)

reval("""
library(RNeo4j)
library(reshape2)
library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(e1071)
library(factoextra)
library(NbClust)
""")

reval("""
graph = startGraph('http://localhost:7475/db/data/', username='', password='')""")

reval("""
query = '
MATCH (s:Senator), (e:edictum)
OPTIONAL MATCH (s)-[v:VOTE]->(e)
WITH s,v,e
MATCH (d:day)-[]->(e)
RETURN e.edictumId as Edicto, s.senator as Senador, v.voted as Votó, d.comission as día
ORDER BY día DESC
'

votos_orig <- cypher(graph,query)

query2 = '
MATCH (s:Senator)
RETURN s.senator as Senador, s.party as Partido
ORDER BY Senador ASC
'
partidos <- cypher(graph,query2)
partidos <- plyr::arrange(partidos,Senador)
votos <- votos_orig[!duplicated(votos_orig),]

votos <- votos[!duplicated(votos[,1:2]),]

votos <- votos %>% spread(Senador,Votó,fill='AUSENTE')
votos\$día <- votos\$día %>% ymd()
""")

reval("""
primertrimestre <- c(1,2,3)
segundotrimestre <- c(4,5,6)
tercertrimestre <- c(7,8,9)
cuartotrimestre <- c(10,11,12)
""")
@rget primertrimestre
@rget segundotrimestre
@rget tercertrimestre
@rget cuartotrimestre
trimestres = [primertrimestre,segundotrimestre,tercertrimestre,cuartotrimestre]
str_trimestre = ["primertrimestre","segundotrimestre","tercertrimestre","cuartotrimestre"]

for año ∈ 2012:2017
    isdir(directorio_fig*"$año") || mkdir(directorio_fig*"$año")
    isdir(directorio_fig*"$año\/png") || mkdir(directorio_fig*"$año\/png")
    isdir(directorio_fig*"$año\/pdf") || mkdir(directorio_fig*"$año\/pdf")
    isdir(directorio_adj*"$año") || mkdir(directorio_adj*"$año")
    isdir(directorio_adj*"$año\/treshold") || mkdir(directorio_adj*"$año\/treshold")
    isdir(directorio_adj*"$año\/weighted") || mkdir(directorio_adj*"$año\/weighted")
    m = 1
    for trimestre ∈ trimestres
        @rput trimestre
        reval("votos_año <- votos[year(votos\$día)==$año,]")
        reval("votos_día <- subset(votos_año, month(votos\$día) %in% trimestre)")

        reval("""
            votos_num <- votos_orig[!duplicated(votos_orig),]
            votos_num <- votos_num[!duplicated(votos_num[,1:2]),]
            votos_num\$Votó <- revalue(votos_num\$Votó,c("EN PRO"=1,"EN CONTRA"=-1,
                                           "AUSENTE"=1, "ABSTENCIÓN"=1))
            votos_num <- votos_num %>% spread(Senador,Votó,fill='1')
            votos_num\$día <- votos_num\$día %>% ymd()
            votos_num_año <- votos_num[year(votos_num\$día)==$año,]
            votos_num_día <- subset(votos_num_año, month(votos_num\$día) %in% trimestre)
            """)

        reval("part_num <- revalue(partidos\$Partido,c('PRI'=1,'PRD'=2,'PAN'=3,'Independiente'=4,'PT'=5,'PVEM'=6))")

        reval("senadores <- c(colnames(votos_num)[3:130])")
        reval("votos_use <- votos_día[apply(votos_num_día,1, function(row){any(row < 0)}),]")
        reval("votos_use <- na.omit(votos_use)")
        @rget votos_use
        edictos = map(x->parse(Float64,x),votos_use[:,1])

        matriz_sumada = zeros(Float64,128,128)
        for numero ∈ edictos
            reval("""edicto <- votos_use[votos_use\$Edicto==$numero,-1:-2]
            occurrences <- table(unlist(edicto))
            num_contra <- occurrences["EN CONTRA"]
            """)
            @rget edicto
            @rget num_contra
            matriz = zeros(Float64,128,128)
            for i in 1:128
                for j in (i+1):128
                    matriz[i,j] = matriz[j,i] = kron_δ(edicto[i],edicto[j])
                end
            end
            matriz = matriz * num_contra
            matriz_sumada = matriz_sumada .+ matriz
        end

        h = Graph(matriz_sumada)
        matriz_sumada = matriz_sumada./extrema(matriz_sumada)[2]
        matriz_pesos = copy(matriz_sumada)

        for indice ∈ eachindex(matriz_sumada)
            if matriz_sumada[indice] >= 0.5
                matriz_sumada[indice] = 1
            else
                matriz_sumada[indice] = 0
            end
        end
        round.(Int64,matriz_sumada)

        g = Graph(matriz_sumada)

        @rget partidos
        los_nombres = partidos[:,1]
        los_partidos = partidos[:,2]

        dic_nom = Dict(i=>los_nombres[i] for i ∈ 1:128)

        isfile(directorio_data*"los_nombres.csv") || writedlm(directorio_data*"los_nombres.csv",los_nombres,',')
        isfile(directorio_data*"los_partidos.csv") || writedlm(directorio_data*"los_partidos.csv",los_partidos,',')

        if ne(g)>0
            sorc = Array{String}(0)
            dest = Array{String}(0)
            peso1 = Array{Float64}(0)
            for e in edges(g)
                push!(sorc,dic_nom[src(e)])
                push!(dest,dic_nom[dst(e)])
                push!(peso1,matriz_pesos[src(e),dst(e)])
            end
            adyacencias = hcat(sorc,dest)
            adyacencias = hcat(adyacencias,peso1)

            sorcp = Array{String}(0)
            destp = Array{String}(0)
            peso = Array{Float64}(0)
            for e in edges(h)
                push!(sorcp,dic_nom[src(e)])
                push!(destp,dic_nom[dst(e)])
                push!(peso,matriz_pesos[src(e),dst(e)])
            end
            adyacenciasp = hcat(sorcp,destp)
            adyacenciasp = hcat(adyacenciasp,peso)

            @rget senadores
            @rget part_num
            globalc = global_clustering_coefficient(g)
            push!(global_clustering,globalc)
            numedges = ne(g)
            push!(global_ne,numedges)
            partidos_num = map(x->parse(Int64,x),part_num)
            los_partidos = Array{Array}(0)
            for partido ∈ [:pri,:prd,:pan,:independiente,:pt,:pvem]
                @eval $partido = Array{Int64}(0)
                push!(los_partidos,@eval $partido)
            end
            for i ∈ 1:length(partidos_num)
                push!(los_partidos[partidos_num[i]],i)
            end
            for i ∈ 1:length(los_partidos)
                subred = induced_subgraph(g,los_partidos[i])[1]
                complemento = setdiff(collect(1:128),los_partidos[i])
                red_complemento = induced_subgraph(g,complemento)[1]
                globclus = global_clustering_coefficient(subred)
                push!(los_cluster[i],globclus)
                globne = ne(subred)
                push!(los_ne[i],globne)
                push!(afuera[i],(ne(g)-globne-ne(red_complemento)))
            end
            promedio = avg_grados(g)
            maximok = max_grados(g)
            push!(avgk,promedio)
            push!(maxk,maximok)
            membership = partidos_num
            nodecolor = [colorant"red",colorant"yellow",colorant"blue",colorant"violet",colorant"orange",colorant"green"]
            #nodecolor = ["#fbb4ae","#ffffcc","#b3cde3","#decbe4","#fed9a6","#ccebc5"]
            nodefillc =  nodecolor[membership]
            draw(PDF(directorio_fig*"$año\/pdf\/"*String(str_trimestre[m])*".pdf", 16cm, 16cm), gplot(g,nodefillc=nodefillc,layout=spring_layout))
            draw(PNG(directorio_fig*"$año\/png\/"*String(str_trimestre[m])*".png", 16cm, 16cm), gplot(g,nodefillc=nodefillc,layout=spring_layout))
            writedlm(directorio_adj*"$año\/"*"treshold/"*String(str_trimestre[m])*"\_$año.dat",adyacencias,'|')
            writedlm(directorio_adj*"treshold/"*String(str_trimestre[m])*"\_$año.dat",adyacencias,'|')
            writedlm(directorio_adj*"$año\/"*"weighted/"*String(str_trimestre[m])*"\_$año.dat",adyacenciasp,'|')
        end
        m += 1
    end
end
n = 1
for partido ∈ nombres_partidos
    writedlm(directorio_clu*"$partido\_cc.csv",los_cluster[n],',')
    writedlm(directorio_ne*"$partido\_in.csv",los_ne[n],',')
    writedlm(directorio_ne*"$partido\_out.csv",afuera[n],',')
    n += 1
end
writedlm(directorio_clu*"global\_cc.csv",global_clustering,',')
writedlm(directorio_ne*"global\_ne.csv",global_ne,',')
writedlm(directorio_k*"k\_promedio.csv",avgk,',')
writedlm(directorio_maxk*"max\_k.csv",maxk,',')
