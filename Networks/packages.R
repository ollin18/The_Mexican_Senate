instalar <- function(paquete) {

  if (!require(paquete,character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)) {
    install.packages(as.character(paquete), repos = "http://cran.us.r-project.org")
    library(paquete, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
  }
}
paquetes <- c('curl','devtools','dplyr', 'tidyr', 'ggplot2',
              'reshape2', 'lubridate','plyr')
lapply(paquetes, instalar);
devtools::install_github("nicolewhite/RNeo4j")
