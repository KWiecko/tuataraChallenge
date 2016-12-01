#'
#'
#'
#' @param
#' @return
#' @export
#'

correlationMatrixCreator <- function(inputDataset){

  library(dplyr)


  # converting dataset to matrix
  inputDatasetMatrix <- inputDataset[,-1] %>%
                        as.matrix(inputDataset)


  inputDataCorrMtx <-round( cor(inputDatasetMatrix,
                          method = "spearman"), 2) # most of variables are categorical/do not have normal distribution



return(inputDataCorrMtx)

}
