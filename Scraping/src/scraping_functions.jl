using Gumbo
using Cascadia
using Requests

export names_and_representations, senators_attendance, alternate_and_titular, senators_votes

num_month = ["01","02","03","04","05","06","07","08","09","10","11","12"]
month = ["enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre", "diciembre"]
dic_month = Dict(month[i]=>num_month[i] for i in 1:length(month))
the_day = r"[0-9]{2}"
the_month = r"(?=de\s)(.*)(?=\s)"
the_year = r"[0-9]{4}"

function get_info(id::Int64)
    r = get("http://www.senado.gob.mx/index.php?watch=8&id=$id")
    #write("../data/info_html/info_senator_$id.html",r.data)
    h = parsehtml(String(copy(r.data)))
    h
end

function giveme_names(element::Array{Gumbo.HTMLNode,1})
    delete_senador = r"\s.*"
    with_title = nodeText(element[1])
    name_only = match(delete_senador, with_title)
    name_only.match[2:end]
end

function giveme_alternate(element::Array{Gumbo.HTMLNode,1})
    nodeText(element[1])
end

function giveme_titid(element::Array{Gumbo.HTMLNode,1})
    delete_bulk = r"d=.*"
    with_bulk = element[1].attributes["href"]
    titid = match(delete_bulk,with_bulk)
    titid.match[3:end]
end

function giveme_states(element::Array{Gumbo.HTMLNode,1})
    delete_bulk_state = r"de\s.*"
    delete_bulk_df = r"el\s.*"
    with_bulk = nodeText(element[2])
    if match(delete_bulk_state, with_bulk) != nothing
        state_only = match(delete_bulk_state, with_bulk)
        state_only.match[4:end]
    elseif match(delete_bulk_df, with_bulk) != nothing
        state_only = match(delete_bulk_df, with_bulk)
        state_only.match[4:end]
    else
        with_bulk
    end
end

function giveme_party(element::Array{Gumbo.HTMLNode,1})
    delete_route = r"os\/.*[^(?:png)]"
    with_route = element[7].attributes["src"]
    if match(delete_route, with_route) != nothing
        party_only = match(delete_route, with_route)
        uppercase(party_only.match[4:end-1])
    else
        party_only = "Independiente"
        party_only
    end
end

function giveme_comissions(element::Array{Gumbo.HTMLNode,1})
    if length(element) != 0
        del_tab = r"\t.*"
        comi = Array{Any}(length(element))
        for i in eachindex(element)
            text = nodeText(element[i])
            if match(del_tab,text) != nothing
                no_tab = match(del_tab,text)
                comi[i]=no_tab.match[2:end]
            else
                comi[i]=text
            end
        end
        comi
        #comission = comi[1]
        #for i in 2:length(comi)
        #    comission = string(comission,"¶",comi[i])
        #end
        #comission
    end
end

function alternate_info(id::Int64)
    h = get_info(id)
    qs = matchall(Selector("div table strong"),h.root)
    alt = matchall(Selector("div span b a"),h.root)
    com = matchall(Selector("div ul li a[href^='index.php?watch=9&sm=100&id']"),h.root)
    name = giveme_names(qs)
    tit_id = giveme_titid(alt)
    comissions = giveme_comissions(com)
    parse(Int64,tit_id), id, name, comissions
end

function names_and_representations(id::Int64)
    tit_id, alt_id, alt_name, alt_com = alternate_info(id)
    h = get_info(tit_id)
    qs = matchall(Selector("div table strong"),h.root)
    pty = matchall(Selector("div table tr td table img"),h.root)
    alt = matchall(Selector("div span b"),h.root)
    com = matchall(Selector("div ul li a[href^='index.php?watch=9&sm=100&id']"),h.root)
    name = giveme_names(qs)
    state = giveme_states(qs)
    party = giveme_party(pty)
    alternate = giveme_alternate(alt)
    if giveme_comissions(com) != nothing
        comissions = giveme_comissions(com)
    else
        comissions = alt_com
    end
    tit_id, name, party, state, comissions, alt_id, alternate
end

function senators_and_alternates(id::Int64)
    tit_id, name, party, state, comissions, alt_id, alternate = names_and_representations(id)
    println(tit_id, "|", name, "|", party, "|", state, "|", alt_id, "|", alternate)
end

function id_and_comissions(id::Int64)
    tit_id, name, party, state, comissions, alt_id, alternate = names_and_representations(id)
    if comissions != nothing
        for i in eachindex(comissions)
            println(tit_id, "|", uppercase(comissions[i]), "|", "PART_OF")
        end
    end
end

function get_info_at(id::Int64)
    r = get("http://www.senado.gob.mx/index.php?watch=35&sm=3&id=$id")
    #write("../data/attendance_html/attendance_senator_$id.html",r.data)
    h = parsehtml(String(copy(r.data)))
    h
end

function giveme_dates(element::Array{Gumbo.HTMLNode,1})
    the_id = r"(?=id=)(.*)(?=&)"
    the_date = r"f=.*"
    mid = Array{Int64}(length(element))
    mda = Array{String}(length(element))
    for i in eachindex(element)
        str=element[i].attributes["href"]
        m_id=match(the_id,str)
        m_date=match(the_date,str)
        mid[i] = parse(Int64,m_id.match[4:end])
        mda[i] = m_date.match[3:end]
    end
    mid, mda
end

function giveme_attendance(element::Array{Gumbo.HTMLNode,1})
    mas = Array{String}(length(element))
    for i in eachindex(element)
        mas[i] = nodeText(element[i])
    end
    mas
end

function senators_attendance(id::Int64)
    the_array = readdlm("data/dic.csv",'|',Int64)
    the_dic = Dict(the_array[i,2]=>the_array[i,1] for i in 1:size(the_array)[1])
    h = get_info_at(id)
    ref = matchall(Selector("tr td div a[href^='index.php?watch=35']"),h.root)
    ref = ref[2:end]
    att = matchall(Selector("tr td div strong"),h.root)[7:end]
    mid, mda = giveme_dates(ref)
    mas = giveme_attendance(att)
    if id < 640
        for attendance in eachindex(ref)
            println(id, "|", mda[attendance], "|", mid[attendance], "|", mas[attendance])
        end
    else
        for attendance in eachindex(ref)
            println(the_dic[id], "|", mda[attendance], "|", mid[attendance], "|", mas[attendance])
        end
    end
end

function get_info_vote(id::Int64)
    r = get("http://www.senado.gob.mx/index.php?watch=36&sm=4&id_sen=$id")
    #write("../data/votes_html/vote_senator_$id.html",r.data)
    h = parsehtml(String(copy(r.data)))
    h
end

function get_info_day(edictum::Int64)
    r = get("http://www.senado.gob.mx/index.php?watch=36&sm=3&ano=2&tp=O&np=2&lg=63&gp=TOTAL&id=$edictum")
    h = parsehtml(String(copy(r.data)))
    h
end



function giveme_the_vote(element::Array{Gumbo.HTMLNode,1})
    the_vote = Array{String}(length(element))
    for i in eachindex(element)
        if nodeText(element[i]) != "AUSENTECOMISIÓN OFICIAL"
            the_vote[i] = nodeText(element[i])
        else
            the_vote[i] = "AUSENTE"
        end
    end
    the_vote
end

function giveme_law_id(element::Array{Gumbo.HTMLNode,1})
    id_law = r"[0-9]{4}"
    lid = Array{Int64}(length(element))
    for i in eachindex(element)
        str = element[i].attributes["href"]
        l_id = match(id_law,str)
        l_id = match(id_law,str)
        lid[i] = parse(Int64,l_id.match)
    end
    lid
end

function senators_votes(id::Int64)
    the_array = readdlm("data/dic.csv",'|',Int64)
    the_dic = Dict(the_array[i,2]=>the_array[i,1] for i in 1:size(the_array)[1])
    h = get_info_vote(id)
    votes = matchall(Selector("td[width='10%'] div[align ='center']"),h.root)
    law = matchall(Selector("tr td div a[href^='index.php?watch=36']"),h.root)
    law = law[2:end]
    the_vote = giveme_the_vote(votes)
    lid = giveme_law_id(law)
    lid = lid[1:2:end]
    if id < 640
        for voting in eachindex(lid)
            println(id, "|", lid[voting], "|", the_vote[voting])
        end
    else
        for voting in eachindex(lid)
            println(the_dic[id], "|", lid[voting], "|", the_vote[voting])
        end
    end
end

function giveme_the_date(edictum::Int64)
    h = get_info_day(edictum)
    date = nodeText(matchall(Selector("tr td div strong"),h.root)[1])
    info = nodeText(matchall(Selector("tr td div"),h.root)[end])
    day = match(the_day,date).match
    month = dic_month[match(the_month,date).match[4:end-3]]
    year = match(the_year,date).match
    the_date = year*"-"*month*"-"*day
    info = replace(info,r"\n",s"")
    info = uppercase(replace(info,r",",s""))
    info, the_date
end

function which_comission(expression, information::String)
    regular = Regex(expression)
    coincide = match(regular,information)
    if coincide != nothing
        coincide.match
    end
end

function all_comission(vector::Array, information::String)
    information = uppercase(information)
    coincidence = Array{Any}(0)
    for i in eachindex(vector)
        each_comission = which_comission(vector[i], information)
        if each_comission != nothing
            push!(coincidence,each_comission)
        end
    end
    if length(coincidence) == 0
        push!(coincidence,"NONE")
    end
    coincidence
end

function giveme_edictum_with_info(edictum::Int64)
    info, the_date = giveme_the_date(edictum)
    coincidence = all_comission(the_comissions, info)
    for i in eachindex(coincidence)
        println(edictum,"|",coincidence[i],"|",info,"|",the_date)
    end
end
