while read -r package;do
yes | julia -e "Pkg.add(\"$package\")"
julia -e "using $package"
done<requirements.txt
yes | rm /root/.julia/lib/v0.6/Compose.ji
