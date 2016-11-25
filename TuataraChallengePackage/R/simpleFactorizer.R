#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'

simpleFactorizer <- function(datasetToFactorize){

  #loading rquired packages
  library(TuataraChallengePackage)
  library(sparklyr)
  library(dplyr)





  # getting columns to factorize
  columnsToFactorize <- datasetToFactorize %>%
    select(contains("cat")) %>%
    colnames()

  for(counter in 2:(length(columnsToFactorize) + 1)){
    # percentage print
    print(paste0("Dataset factorized in ", round(100 * counter/(length(columnsToFactorize) + 1), 2) , "%"))

    datasetToFactorize[, counter] <- factor(as.vector(unlist(datasetToFactorize[, counter])),
                                     labels = c(1:length(levels(factor(as.vector(unlist(datasetToFactorize[, counter]))))) ) ) %>%
                                     unlist() %>%
                                     as.vector() %>%
                                     as.integer()
  }

  return(datasetToFactorize);

}
