instalar <- function(paquete) {

  if (!require(paquete,character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)) {
    install.packages(as.character(paquete), repos = "http://cran.us.r-project.org")
    library(paquete, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
  }
}
paquetes <- c('dplyr', 'tidyr', 'ggplot2',
              'reshape2', 'lubridate','plyr')
packageurl <- "https://cran.r-project.org/src/contrib/Archive/RNeo4j/RNeo4j_1.6.4.tar.gz"
install.packages(packageurl, contriburl=NULL, type="source")

lapply(paquetes, instalar);
