#'
#'
#'
#' @param
#' @return
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
