#!/usr/bin/env julia

using OhMyREPL
using LightGraphs
using Plots
pyplot()
include("read_graph.jl")

eigenvalores = @animate for mes ∈ 1:20
    g,no,dino = lectura(mes)
    A = adjacency_matrix(g)
    the_val = eigvals(full(A))
    histogram(the_val,nbins=20)
end
gif(eigenvalores,"/figs/animacion_valores.gif",fps=5)

erdos = @animate for mes ∈ 1:20
    g = erdos_renyi(128,rand())
    A = adjacency_matrix(g)
    the_val = eigvals(full(A))
    histogram(the_val,nbins=100)
end
gif(erdos,"/figs/eigv_erdos.gif",fps=5)

ws = @animate for mes ∈ 1:20
    g = watts_strogatz(128,50,0.6)
    A = adjacency_matrix(g)
    the_val = eigvals(full(A))
    histogram(the_val,nbins=100)
end
gif(ws,"/figs/eigv_watts_strogatz.gif",fps=5)

random = @animate for mes ∈ 1:20
    A = [rand() for i in 1:128,j in 1:128]
    for i in 1:128
        for j in 1:128
            A[j,i] = A[i,j]
        end
    end
    the_val = eigvals(A)
    histogram(the_val,nbins=100)
end
gif(erdos,"/figs/eigv_erdos.gif",fps=5)

