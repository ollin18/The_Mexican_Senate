#!/usr/bin/env julia

using OhMyREPL
using RCall
using LightGraphs
using GraphPlot
using Colors
using Compose
using Clustering
using RCall
include("utils.jl")
include("matrices.jl")

R_kmeans = R"kmeans";
c_in = Array{Int64}(0)
c_out = Array{Int64}(0)

nombres_partidos = ["pri","prd","pan","independiente","pt","pvem"]
directorio_data = "/data/"
directorio_adj = directorio_data*"adj/"
directorio_clu = directorio_data*"clustering/"
directorio_ne = directorio_data*"edges/"
directorio_fig = "/figs/"
directorio_pdf = "/figs/pdf/"
directorio_png = "/figs/png/"
isdir(directorio_data) || mkdir(directorio_data)
isdir(directorio_adj) || mkdir(directorio_adj)
isdir(directorio_adj*"threshold/") || mkdir(directorio_adj*"threshold/")
isdir(directorio_adj*"weighted/") || mkdir(directorio_adj*"weighted/")
isdir(directorio_clu) || mkdir(directorio_clu)
isdir(directorio_ne) || mkdir(directorio_ne)
isdir(directorio_fig) || mkdir(directorio_fig)
isdir(directorio_pdf) || mkdir(directorio_pdf)
isdir(directorio_png) || mkdir(directorio_png)

reval("""
library(RNeo4j)
library(reshape2)
library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

graph = startGraph('http://localhost:7474/db/data/', username='neo4j')

query = '
MATCH (s:Senator), (e:edictum)
OPTIONAL MATCH (s)-[v:VOTE]->(e)
WITH s,v,e
MATCH (d:day)-[]->(e)
RETURN e.edictumId as Edicto, s.senator as Senador, v.voted as Votó, d.day as día
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

for año ∈ 2012:2018
    isdir(directorio_fig*"$año") || mkdir(directorio_fig*"$año")
    isdir(directorio_fig*"$año\/png") || mkdir(directorio_fig*"$año\/png")
    isdir(directorio_fig*"$año\/pdf") || mkdir(directorio_fig*"$año\/pdf")
    isdir(directorio_pdf*"$año/") || mkdir(directorio_pdf*"$año/")
    isdir(directorio_png*"$año/") || mkdir(directorio_png*"$año/")
    isdir(directorio_clu*"$año/") || mkdir(directorio_clu*"$año/")
    m = 1
    for u ∈ 1:length(trimestres)
        trimestre = trimestres[u]
        @rput trimestre
        reval("""
            votos_año <- votos[year(votos\$día)==$año,]
            votos_día <- subset(votos_año, month(votos\$día) %in% trimestre)
        """)

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
        no_diag = matriz_sumada+eye(128).*maximum(matriz_sumada)
        prop_no_zero = (128^2 - count(x->x==0,no_diag))/128^2
        matriz_copiada = copy(matriz_sumada)

        for indice ∈ eachindex(matriz_sumada)
            if matriz_sumada[indice] >= 0.5
                matriz_sumada[indice] = 1
            else
                matriz_sumada[indice] = 0
            end
        end
        round.(Int64,matriz_sumada)

        g = Graph(matriz_sumada)

        if ne(g)>0
            NBM, edgeidmap = ollin_matrix(g,matriz_copiada)
            grad = [force(g,i,matriz_copiada) for i in 1:128]
            threshold = 4*sqrt(mean(grad)/mean(grad.-1)/mean(grad))

            R = NBM
            valores, vectores = eigens(R,threshold)
            cuantos, index = num_com(valores,threshold)
            if cuantos < 2
                threshold = 3*sqrt(mean(grad)/mean(grad.-1)/mean(grad))
                valores, vectores = eigens(R,threshold)
                cuantos, index = num_com(valores,threshold)
            end

            matriz_embedded = real(vectores[:,index])
            contraida = contraccion(g,index,matriz_embedded,edgeidmap)
            sign_switch = sum(x->sign(real(x)), contraida[:,1])
            valores

            #if prop_no_zero>0.5 && length(index)>1 && abs(sign_switch) == 128
                index = index[2:length(index)]
                matriz_embedded = real(vectores[:,index])
                contraida = contraccion(g,index,matriz_embedded,edgeidmap)
            #else
                #index = index
                #matriz_embedded = matriz_embedded
                #contraida = contraida
            #end

            grupos = kmeans(contraida',length(index)+1;init=:kmcen)
            grupos = assignments(grupos)

            #comunidades = hcat(vertices(g),grupos)
            #writedlm("comunidadesollin.dat",comunidades,',')
            membership = grupos
            nodecolor = [colorant"red",colorant"yellow",colorant"blue",colorant"violet",colorant"orange",colorant"green"]
            nodefillc =  nodecolor[membership]
            el_senador = readdlm("../data/los_nombres.csv",',')
            el_partido = readdlm("../data/los_partidos.csv",',')
            noditos = hcat(el_senador,membership,el_partido)
            writedlm(directorio_clu*"$año\/"String(str_trimestre[m])*"grupos\_ollin.dat",noditos)
            draw(PDF(directorio_pdf*"\/$año\/"*String(str_trimestre[m])*"\_ollin.pdf", 16cm, 16cm), gplot(g,nodefillc=nodefillc,layout=spring_layout))
            draw(PNG(directorio_png*"\/$año\/"*String(str_trimestre[m])*"\_ollin.png", 16cm, 16cm), gplot(g,nodefillc=nodefillc,layout=spring_layout))

            ##### Aquí va la medición de asortatividad
            adentro = Array{Int64}(0)
            afuera = Array{Int64}(0)
            for i ∈ 1:maximum(membership)
                the_group = Array{Int64}(0)
                for j ∈ eachindex(membership)
                    if membership[j] == i
                        push!(the_group,j)
                    end
                end
                subred = induced_subgraph(g,the_group)[1]
                complemento = setdiff(collect(1:128),the_group)
                red_complemento = induced_subgraph(g,complemento)[1]
                ##globclus = global_clustering_coefficient(subred)
                ##push!(los_cluster[i],globclus)
                globne = ne(subred)
                push!(adentro,globne)
                push!(afuera,(ne(g)-globne-ne(red_complemento)))
            end
            push!(c_in,sum(adentro))
            push!(c_out,sum(afuera))
            println(año,",",str_trimestre[m])
        end
        m += 1
    end
end

writedlm(directorio_ne*"langle\_in.csv",c_in,',')
writedlm(directorio_ne*"langle\_out.csv",c_out,',')
