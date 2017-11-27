using OhMyREPL
using Plots
pyplot()
#gr()

directorio_data = "../data/"
directorio_adj = directorio_data*"adj/"
directorio_clu = directorio_data*"clustering/"
directorio_ne = directorio_data*"edges/"
directorio_fig = "../figs/"
directorio_fig_plots = directorio_fig*"plots/"
directorio_ratio = directorio_fig_plots*"ratio/"
directorio_png = directorio_ratio*"png/"
directorio_pdf = directorio_ratio*"pdf/"
isdir(directorio_fig_plots) || mkdir(directorio_fig_plots)
isdir(directorio_ratio) || mkdir(directorio_ratio)
isdir(directorio_png) || mkdir(directorio_png)
isdir(directorio_pdf) || mkdir(directorio_pdf)


pri_in = readdlm(directorio_ne*"pri_in.csv")
prd_in = readdlm(directorio_ne*"prd_in.csv")
pan_in = readdlm(directorio_ne*"pan_in.csv")
independiente_in = readdlm(directorio_ne*"independiente_in.csv")
pt_in = readdlm(directorio_ne*"pt_in.csv")
pvem_in = readdlm(directorio_ne*"pvem_in.csv")
pri_pvem_in = readdlm(directorio_ne*"pri_verde_in.csv")
prd_pt_in = readdlm(directorio_ne*"prd_pt_in.csv")
izquierdas_in = readdlm(directorio_ne*"izquierdas_in.csv")
derechas_in = readdlm(directorio_ne*"derechas_in.csv")
pan_izquierdas_in = readdlm(directorio_ne*"pan_izquierdas_in.csv")
langle_in = readdlm(directorio_ne*"langle_in.csv")

pri_out = readdlm(directorio_ne*"pri_out.csv")
prd_out = readdlm(directorio_ne*"prd_out.csv")
pan_out = readdlm(directorio_ne*"pan_out.csv")
independiente_out = readdlm(directorio_ne*"independiente_out.csv")
pt_out = readdlm(directorio_ne*"pt_out.csv")
pvem_out = readdlm(directorio_ne*"pvem_out.csv")
pri_pvem_out = readdlm(directorio_ne*"pri_verde_out.csv")
prd_pt_out = readdlm(directorio_ne*"prd_pt_out.csv")
izquierdas_out = readdlm(directorio_ne*"izquierdas_out.csv")
derechas_out = readdlm(directorio_ne*"derechas_out.csv")
pan_izquierdas_out = readdlm(directorio_ne*"pan_izquierdas_out.csv")
langle_out = readdlm(directorio_ne*"langle_out.csv")

partido_in = [pri_in,prd_in,pan_in,independiente_in,pt_in,pvem_in]
partido_out = [pri_out,prd_out,pan_out,independiente_out,pt_out,pvem_out]
los_partidos = ["PRI","PRD","PAN","IND","PT","PVEM"]
coalicion_in = [pri_pvem_in,prd_pt_in,izquierdas_in,derechas_in,pan_izquierdas_in]
coalicion_out = [pri_pvem_out,prd_pt_out,izquierdas_out,derechas_out,pan_izquierdas_out]
las_coaliciones = ["PRI-PVEM","PRD-PT","Izquierdas","Derechas","PAN-Izquierdas"]

time = collect(1:length(pri_in))
x = time
for i ∈ 1:6
    cual = los_partidos[i]
    ratio = partido_in[i] ./ partido_out[i]
    bounds = (0,2)
    bounds = extrema(ratio)
    plot(x,ratio,lab="Ratio",xaxis=("Time (trimester)"),yaxis=("Ratio in/out",bounds,linspace(bounds[1],bounds[2],20)))
    title!("in/out ratio for "*cual)
    savefig(directorio_png*cual*"\_ratio.png")
    savefig(directorio_pdf*cual*"\_ratio.pdf")
end

for i ∈ 1:5
    cual = las_coaliciones[i]
    ratio = coalicion_in[i] ./ coalicion_out[i]
    if maximum(ratio) > 2
        bounds = (0,maximum(ratio))
    else
        bounds = (0,2)
    end
    bounds = extrema(ratio)
    plot(x,ratio,lab="Ratio",xaxis=("Time (trimester)"),yaxis=("Ratio in/out",bounds,linspace(bounds[1],bounds[2],20)))
    title!("in/out ratio for "*cual)
    savefig(directorio_png*cual*"\_ratio.png")
    savefig(directorio_pdf*cual*"\_ratio.pdf")
end

all_parties=union(pri_in./pri_out,prd_in./prd_out,pan_in./pan_out,independiente_in./independiente_out,pt_in./pt_out,pvem_in./pvem_out)
bounds=extrema(all_parties)
plot(x,pri_in./pri_out,lab="PRI",c=:red,xaxis=("Time (trimester)"),yaxis=("Ratio in/out",bounds,linspace(bounds[1],bounds[2],20)))
plot!(x,prd_in./prd_out,lab="PRD",c=:yellow)
plot!(x,pan_in./pan_out,lab="PAN",c=:blue)
plot!(x,independiente_in./independiente_out,lab="IND",c=:violet)
plot!(x,pt_in./pt_out,lab="PT",c=:orange)
plot!(x,pvem_in./pvem_out,lab="PVEM",c=:green)
title!("in/out edges ratio")
savefig(directorio_png*"todos\_ratio.png")
savefig(directorio_pdf*"todos\_ratio.pdf")

ratio = derechas_in ./ derechas_out
bounds = (0,maximum(ratio))
plot(x,derechas_in./derechas_out,lab="Derechas",c=:red,xaxis=("Time (trimester)"),yaxis=("Ratio in/out",bounds,linspace(bounds[1],bounds[2],20)))
plot!(x,pri_pvem_in./pri_pvem_out,lab="PRI-PVEM",c=:green)
plot!(x,prd_pt_in./prd_pt_out,lab="PRD-PT",c=:yellow)
plot!(x,izquierdas_in./izquierdas_out,lab="Izquierdas",c=:black)
plot!(x,pan_izquierdas_in./pan_izquierdas_out,lab="PAN-Izquierdas",c=:blue)
title!("in/out edges ratio coalitions")
savefig(directorio_png*"todos_coaliciones\_ratio.png")
savefig(directorio_pdf*"todos_coaliciones\_ratio.pdf")


#### Communities detectability treshold

c_in = pri_in+prd_in+pan_in+independiente_in+pt_in+pvem_in
c_out = pri_out+prd_out+pan_out+independiente_out+pt_out+pvem_out
c = (c_in+c_out)/2 # grado promedio
treshold = 2*sqrt.(c)
all_values = union(c_in-c_out,treshold)
bounds=(minimum(all_values),maximum(all_values))
plot(x,treshold,lab="2√<k>",c=:red,xaxis=("Time (trimester)"),yaxis=("Community treshold",bounds,bounds[1]:200:bounds[2]))
plot!(x,c_in-c_out,lab="c_in-c_out",c=:blue)
title!("Assortativity by party")
savefig(directorio_png*"assortativity_party.png")
savefig(directorio_pdf*"assortativity_party.pdf")

#### Communities detectability treshold coalitions

c_in = derechas_in + izquierdas_in
c_out = derechas_out + izquierdas_out
c = (c_in+c_out)/2 # grado promedio
treshold = 2*sqrt.(c)
all_values = union(c_in-c_out,treshold)
bounds=(minimum(all_values),maximum(all_values))
plot(x,treshold,lab="2√<k>",c=:red,xaxis=("Time (trimester)"),yaxis=("Community treshold",bounds,linspace(bounds[1],bounds[2],20)))
plot!(x,c_in-c_out,lab="c_in-c_out",c=:blue)
title!("Assortativity by right-left")
savefig(directorio_png*"assortativity_right-left.png")
savefig(directorio_pdf*"assortativity_right-left.pdf")

#### Communities detectability treshold coalitions

c_in = pri_pvem_in + pan_in + izquierdas_in
c_out = pri_pvem_out + pan_out + derechas_out
c = (c_in+c_out)/2 # grado promedio
treshold = 2*sqrt.(c)
all_values = union(c_in-c_out,treshold)
bounds=(minimum(all_values),maximum(all_values))
plot(x,treshold,lab="2√<k>",c=:red,xaxis=("Time (trimester)"),yaxis=("Community treshold",bounds,linspace(bounds[1],bounds[2],20)))
plot!(x,c_in-c_out,lab="c_in-c_out",c=:blue)
title!("Assortativity by PRI/PVEM-PAN-Left")
savefig(directorio_png*"assortativity_pripvem-pan-izq.png")
savefig(directorio_pdf*"assortativity_pripvem-pan-izq.pdf")

#### Communities detectability treshold langle

c_in = langle_in
c_out = langle_out
c = (c_in+c_out)/2 # grado promedio
treshold = 2*sqrt.(c)
all_values = union(c_in-c_out,treshold)
bounds=(minimum(all_values),maximum(all_values))
plot(x,treshold,lab="2√<k>",c=:red,xaxis=("Time (trimester)"),yaxis=("Community treshold",bounds,linspace(bounds[1],bounds[2],20)))
plot!(x,c_in-c_out,lab="c_in-c_out",c=:blue)
title!("Assortativity by communities")
savefig(directorio_png*"assortativity_langle.png")
savefig(directorio_pdf*"assortativity_langle.pdf")

#### Communities detectability treshold langle vs left-right

c_in = langle_in
c_out = langle_out
c = (c_in+c_out)/2 # grado promedio
wings_in = derechas_in + izquierdas_in
wings_out = derechas_out + izquierdas_out
treshold = 2*sqrt.(c)
all_values = union(c_in-c_out,treshold)
bounds=(minimum(all_values),maximum(all_values))
plot(x,treshold,lab="2√<k>",c=:red,xaxis=("Time (trimester)"),yaxis=("Community treshold",bounds,linspace(bounds[1],bounds[2],20)))
plot!(x,c_in-c_out,lab="c_in-c_out (Communities)",c=:blue)
plot!(x,wings_in-wings_out,lab="c_in-c_out(Left-Right)",c=:olive)
title!("Assortativity Communities vs Left-Right wings")
savefig(directorio_png*"assortativity_communities_rl.png")
savefig(directorio_pdf*"assortativity_communities_rl.pdf")
