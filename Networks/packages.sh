while read -r package;do
julia -e "Pkg.add(\"$package\")"
julia -e "using $package"
done<requirements.txt
