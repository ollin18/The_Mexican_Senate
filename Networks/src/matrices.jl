#!/usr/bin/env julia
function NB_matrix(g)
	A = full(adjacency_matrix(g))
    ceros = zeros(A)
    D = zeros(A)
    menos = -1 * eye(A)
    for n in 1:nv(g)
        D[n,n] = degree(g,n)-1
    end
    sparse(hcat(vcat(ceros,menos),vcat(D,A)))
end

function mapa(g)
    edgeidmap = Dict{Edge, Int}()
    aristas = ne(g)
    m = 0
    for e in edges(g)
        m += 1
        edgeidmap[e] = m
        edgeidmap[reverse(e)] = m + aristas
    end
    edgeidmap, m, aristas
end

function flux_matrix(g)

    edgeidmap, m, aristas = mapa(g)

    B = zeros(Float64, 2*aristas, 2*aristas)

    for (e,u) in edgeidmap
        i, j = src(e), dst(e)
        eles = neighbors(g,j)
        k = j
        for l in eles
            B[edgeidmap[Edge(k,l)],u] = (kron_δ(j,k)*(1-kron_δ(i,l)))*(1/(degree(g,j)))
        end
    end
    return B, edgeidmap
end

function reluctant_matrix(g)

    edgeidmap, m, aristas = mapa(g)

    B = zeros(Float64, 2*aristas, 2*aristas)

    for (e,u) in edgeidmap
        i, j = src(e), dst(e)
        eles = neighbors(g,j)
        k = j
        for l in eles
            B[edgeidmap[Edge(k,l)],u] = (kron_δ(j,k)*(1-kron_δ(l,i)))+(kron_δ(j,k)*kron_δ(l,i)*inv_degree(g,j))
        end
    end
    return B, edgeidmap
end

function normalized_reluctant(g)

    edgeidmap, m, aristas = mapa(g)

    B = zeros(Float64, 2*aristas, 2*aristas)


    for (e,u) in edgeidmap
        i, j = src(e), dst(e)
        eles = neighbors(g,j)
        k = j
        for l in eles
            B[edgeidmap[Edge(k,l)],u] = ((kron_δ(j,k)*(1-kron_δ(i,l)))+(kron_δ(j,k)*kron_δ(l,i)*inv_degree(g,j)))*(1/((degree(g,i)-1)+inv_degree(g,j)))
        end
    end
    return B, edgeidmap
end

function ollin_matrix(g,v)

    edgeidmap, m, aristas = mapa(g)

    B = zeros(Float64, 2*aristas, 2*aristas)

    for (e,u) in edgeidmap
        i, j = src(e), dst(e)
        eles = neighbors(g,j)
        k = j
        for l in eles
            #  B[edgeidmap[Edge(k,l)],u] =
            #  (kron_δ(j,k)*(1-kron_δ(i,l))) * harmean(v[i,j],v[k,l])*(inv_degree_ollin(g,l,v)) + rel_single(g,j)* inv_degree_ollin(g,j,v)
            #  (kron_δ(j,k)*(1-kron_δ(i,l)))*((2/(1/v[i,j]+1/v[k,l]))*(inv_degree_ollin(g,l,v)))
            #  (kron_δ(j,k)*(1-kron_δ(i,l)))* harmean(v[i,j],v[k,l])*(inv_degree_ollin(g,l,v)) + inv_degree_ollin(g,j,v)

            B[edgeidmap[Edge(k,l)],u] = (kron_δ(j,k)*(1-kron_δ(i,l)) )*(2/(1/v[i,j]+1/v[k,l]))*(inv_degree(g,l)) + rel_single(g,k)*inv_degree(g,j)
        end
    end
    return B, edgeidmap
end

