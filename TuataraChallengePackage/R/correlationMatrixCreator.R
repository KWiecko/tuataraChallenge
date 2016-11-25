#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'

correlationMatrixCreator <- function(inputDataset){

  library(dplyr)
  # library(car)
  # library(nortest)
  # library(fBasics)
  # library(corrplot)
  # library(corrgram)
  # library(PerformanceAnalytics)
  # library(jmuOutlier)
  # library(PairedData)
  # library(corrr)
  # library(energy)
  # library(purrr)

  # converting dataset to matrix
  inputDatasetMatrix <- inputDataset[,-1] %>%
                        as.matrix(inputDataset)


  inputDataCorrMtx <-round( cor(inputDatasetMatrix,
                          method = "spearman"), 2) # most of variables are categorical/do not have normal distribution



return(inputDataCorrMtx)

}
