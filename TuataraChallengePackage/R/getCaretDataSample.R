#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'


getCaretDataSample <- function(dataFrameToSplit, columnToSplitBy, nOfRows, nOfSplits, localSeed){

  library(caret)
  library(dplyr)

  pParam <- round(nOfRows/length(dataFrameToSplit[,1] %>% unlist() %>% as.vector()), 3)

  set.seed(localSeed)
  subsetIdx <- createDataPartition(columnToSplitBy, p = pParam, times = nOfSplits)
  listOfTrimmedDatasets <- lapply(subsetIdx, function(x){
                                                                  return(dataFrameToSplit[x,])
                                                                  })


}
