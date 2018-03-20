# The_Mexican_Senate
Repo for data adquisition, database creation and network analysis of the Mexican Senate.

In this branch we only have two dependencies, *docker* and *docker-compose*.
In order to run the pipeline you have to be under the **Infrastructure** directory and run:
```
docker-compose up
```
The docker containers will be build and run in dependency order, be patient it may take a while.

If for any reason the network analysis didn't do what it was supposed to just run the single container from
the root directory of this repo.
```
docker run -v $(pwd)/data/:/data/ -v $(pwd)/figs/:/figs/ --net=host ollin18/senate_net:0.1
```

For a visualization of the dynamics of the Senate's network follow:
[![Dynamics](https://img.youtube.com/vi/3Yi6x6CwxPg/0.jpg)](https://www.youtube.com/watch?v=3Yi6x6CwxPg)

## This repo scraps all the information we need from [senado](https://www.senado.gob.mx),
then uploads everything to a Neo4j database and uses that to perform network analysis.
Everything is done using JuliaLang with a little help from R.

If you only want to play with the database without the need of scrap the information, you should run:
```
docker run --rm  -d\
    --publish=7474:7474 --publish=7687:7687 \
    --volume=$HOME/neo4j/data:/data \
    --volume=$HOME/neo4j/logs:/logs \
    --env=NEO4J_AUTH=none \
    ollin18/base_nueva
```
It's kind of obvious that you have to install docker-engine first.
The past command will give you the Senate's information until October/19/2017

The information used to be up to date on a S3 but my free period expired so I'll move this to GCP.

TODO:
Write the luigi pipeline and move the network analysis to docker.
