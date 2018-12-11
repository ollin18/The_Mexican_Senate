using LightGraphs
exten = r".dat"

function ext(v::Regex)
    valid = Array{Any}(undef,0)
  for i in readdir("../data/adj/treshold")
    if match(v,i) != nothing
      push!(valid,i)
    end
  end
  valid
end

a = ext(exten)

graph_files = Dict{String,Int64}(Dict(a[i]=>i for i in 1:length(a)))

function lectura(numero)
    ad_list = a[numero]
    red = readdlm("../data/adj/treshold/$ad_list",'|')
    if typeof(red[1,1]) == Float64 && typeof(red[1,2]) == Float64
        red = round(Int64,red)
    end
        i = 1
        j = 2

    if typeof(red[1,i]) != Int
        Nodes = readdlm("../data/los_nombres.csv",',')
        dic_nodes = Dict{String,Int64}(Dict(Nodes[i]=>i for i in 1:length(Nodes)))
        g = Graph()
        last_node = Int64(length(Nodes))
        add_vertices!(g,last_node)
        for n in 1:Int64(size(red)[1])
          add_edge!(g,dic_nodes[red[n,i]],dic_nodes[red[n,j]])
        end
    else
        g = Graph()
        last_node = Int64(maximum(red))
        add_vertices!(g,last_node)
        for n in 1:Int64(size(red)[1])
          add_edge!(g,Int64(red[n,i]),Int64(red[n,j]))
        end
    end

    print("\n")
    if typeof(red[1,i]) != Int
    return g, Nodes, dic_nodes
    else
    return g
    end
end
