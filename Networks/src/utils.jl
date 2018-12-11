#!/usr/bin/env julia
function kron_δ(i,j)
    if i == j
        return 1
    else
        return 0
    end
end

function harmean(i,j)
    2 / ((1/i)+(1/j))
end

function inv_degree(g,i)
    1/degree(g,i)
end

function force(g,i,v)
    force = sum(v[:,i])
    force
end

function inv_degree_ollin(g,i,v)
    try
        1/force(g,i,v)
    catch
        0
    end
end

function rel_single(g,i)
    if degree(g,i) == 1
        1
    else
        0
    end
end

function mglobal_clustering_coefficient(g::AbstractGraph)
    c = 0
    ntriangles = 0
    for v in vertices(g)
        neighs = neighbors(g, v)
        for i in neighs, j in neighs
            i == j && continue
            if has_edge(g, i, j)
                c += 1
            end
        end
        k = degree(g, v)
        ntriangles += k * (k - 1)
    end
    ntriangles == 0 && return 0.
    return c / ntriangles
end

function inv_degree_N(g,i)
    if degree(g,i) != 1
        1/(degree(g,i)-1)
    else
        1/degree(g,i)
    end
end

function nonBM_embedding(g)
  NB = la_NBM(g)
  λ, eigve = eigs(NB, nev=20)
  los_reales = Array{Float64}(0)
  los_indices_reales = Array{Int64}(0)
  for i in 1:length(λ)
        if imag(λ[i]) == 0 && real(λ[i]) != 0 && i*real(λ[i]) >= sqrt(real(λ[1]))
          push!(los_reales,λ[i])
          push!(los_indices_reales,i)
      end
  end
  matriz_embedded = sub(real(eigve),:,los_indices_reales)
  length(los_reales), los_indices_reales
  ϕ = zeros(Float64, nv(g), length(los_reales))
  for n=1:(length(los_reales))
      v= matriz_embedded[:,n]
      ϕ[:,n] = contrae(g, v)
  end
  return length(los_reales), ϕ
end

function grados(g)
	grados = Array{Int64}(0)
	gradosdiv = Array{Int64}(0)
	for i in vertices(g)
		push!(grados,degree(g,i))
	end
	grados
end

function avg_grados(g)
    grado = grados(g)
    avg_grad = mean(grado)
    avg_grad
end

function max_grados(g)
    grado = grados(g)
    maxi = maximum(grado)
    maxi
end

function mat_an(g,v,NBM)
	unos = ones(2ne(g))/sqrt(2ne(g))
	unnos = unos*unos'
	R = NBM - unnos
	R
end


function eigens(M,treshold)
	valores, vectores = eigs(M,which=:LR,nev=3)
        if real(last(valores)) > treshold
		valores, vectores = eigs(M,which=:LR,nev=4)
		if real(last(valores)) > treshold
		    valores, vectores = eigs(M,which=:LR,nev=5)
		    if real(last(valores)) > treshold
		        valores, vectores = eigs(M,which=:LR,nev=10)
		        if real(last(valores)) > treshold
		            valores, vectores = eigs(M,which=:LR,nev=nv(g))
		        end
		    end
		end
	end
	valores, vectores
end



function num_com(v,treshold)
	cuantos = Array{Float64}(0)
	index = Array{Int64}(0)
	for i in 1:length(v)
		if imag(v[i]) == 0 && real(v[i]) > treshold
		    push!(cuantos,real(v[i]))
		    push!(index,i)
		end
	end
        #if index[1] == 1
            #index = index[2:length(index)]
        #end
	cuantos = length(cuantos)
	cuantos, index
end


function embe_nbm(g,ind,vec)
	reales = real(vectores[:,index])
	arriba = reales[1:nv(g),:]
	abajo = reales[nv(g)+1:2*nv(g),:]
	matriz_embedded = arriba + abajo
	matriz_embedded
end

function contrae(g,v,ei)
    y = zeros(Float64, nv(g))
    for i in 1:nv(g)
        for j in neighbors(g,i)
            u = ei[Edge(j,i)]
            y[i] += v[u]
            y[j] += v[u]
        end
    end
    y
end

function contraccion(g,vec,emb,ei)
	contraida = zeros(Float64, nv(g), length(vec))
	for n in 1:length(vec)
    	contraida[:,n] = contrae(g,emb,ei)
	end
	contraida
end

function membresia(n,v)
    membresia = Array{Int64}(0)
    if n == 2
        for i in 1:length(v[:,1])
            if sign(v[i,1]) == sign(1)
                push!(membresia,1)
            else
                push!(membresia,2)
            end
        end
    else
        matriz_sirve = v
        cluster_p = R_kmeans(matriz_sirve[:,1:n-1],n,nstart=500)
        for i in 1:length(cluster_p[1])
            push!(membresia,cluster_p[1][i])
        end
    end
    membresia
end

function opinion(g)
    opiniones = ones(nv(g))
    opiniones = [opiniones[i] * rand([-1 ,1]) for i in 1:length(opiniones)]
    convert(Array{Int64},opiniones)
end

function probabilidad(p)
    if rand() <= p
        return 1
    else
        return -1
    end
end

function voter_model(g)
    av_op=Array{Float64}(undef,0)
    op = opinion(g)
    while abs(sum(op)/length(op))!=1
        push!(av_op,sum(op)/length(op))
        seleccionado = rand(collect(1:nv(g)))
        opinion_seleccionado = op[seleccionado]
        vecinos = neighbors(g, seleccionado)
        vecino_sel = rand(vecinos)
        op[seleccionado] = op[vecino_sel]
    end
    the_time = length(av_op)
end

function sznajd_one(g)
    av_op=Array{Float64}(undef,0)
    op = opinion(g)
    while abs(sum(op)/length(op))!=1
        push!(av_op,sum(op)/length(op))
        seleccionado = rand(collect(1:nv(g)))
        opinion_seleccionado = op[seleccionado]
        vecinos = neighbors(g, seleccionado)
        op[vecinos] .= opinion_seleccionado
    end
    the_time = length(av_op)
end

function sznajd_two(g)
    av_op=Array{Float64}(undef,0)
    op = opinion(g)
    while abs(sum(op)/length(op))!=1
        push!(av_op,sum(op)/length(op))
        seleccionado = rand(collect(1:nv(g)))
        opinion_seleccionado = op[seleccionado]
        vecinos = neighbors(g, seleccionado)
        opinion_vecino = op[rand(vecinos)]
        if opinion_seleccionado == opinion_vecino
            op[vecinos] .= opinion_seleccionado
        end
    end
    the_time = length(av_op)
end

function sznajd_three(g)
    av_op=Array{Float64}(undef,0)
    op = opinion(g)
    while abs(sum(op)/length(op))!=1
        push!(av_op,sum(op)/length(op))
        seleccionado = rand(collect(1:nv(g)))
        opinion_seleccionado = op[seleccionado]
        vecinos = neighbors(g, seleccionado)
        vecino1 = rand(vecinos)
        vecino2 = rand(vecinos)
        if vecino1 == vecino2
            while vecino1 == vecino2
                vecino2 = rand(vecinos)
            end
        end
        opinion_vecino1 = op[vecino1]
        opinion_vecino2 = op[vecino2]
        if opinion_seleccionado == opinion_vecino1 == opinion_vecino2
            op[vecinos] .= opinion_seleccionado
        end
    end
    the_time = length(av_op)
end
