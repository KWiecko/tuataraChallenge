#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'
#'

adjRsq <- function(testDataset, predictionDataset, nObs, nPred, isLossLog){

  adjRsqDF <- data.frame(testDataset$loss, predictionDataset$prediction)

  names(adjRsqDF) <- c("loss", "pred")

  if(isLossLog){
    adjRsqDF <- adjRsqDF %>% mutate(loss = exp(loss), pred = exp(pred))
  }

  meanLoss <- mean(testDataset$loss)
  adjRsqDF <- adjRsqDF %>% mutate(rSQLicz = (pred - meanLoss)^2, rSQMian = (loss - meanLoss)^2, rmseLicz = (pred-loss)^2)
  Rsq <- sum(adjRsqDF$rSQLicz)/sum(adjRsqDF$rSQMian)

  adjRsq <- 1 - (1-Rsq)*(nObs - 1)/(nObs - nPred - 1)
  RMSE <- sum(adjRsqDF$rmseLicz)/length(adjRsqDF$loss)

  adjRsqList <- list(adjRsq, RMSE)

  return(adjRsqList)
}
