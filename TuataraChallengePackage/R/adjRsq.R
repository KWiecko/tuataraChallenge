#'
#'
#'
#' @param
#' @return
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
  adjRsqDF <- adjRsqDF %>% mutate(rSQLicz = (pred - meanLoss)^2, rSQMian = (loss - meanLoss)^2, rmseLicz = (pred-loss)^2, absoluteDiffFrac = abs(pred-loss)/loss)
  Rsq <- sum(adjRsqDF$rSQLicz)/sum(adjRsqDF$rSQMian)

  adjRsq <- 1 - (1-Rsq)*(nObs - 1)/(nObs - nPred - 1)
  MSE <- sum(adjRsqDF$rmseLicz)/length(adjRsqDF$loss)

  verificationDF <- adjRsqDF %>% select(loss, pred, absoluteDiffFrac)

  adjRsqList <- list(adjRsq, Rsq, MSE, verificationDF)
  names(adjRsqList) <- c("Rsq_adj", "Rsq", "MSE", "absoluteDiff")

  return(adjRsqList)
}
