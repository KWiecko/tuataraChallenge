#'
#'
#'
#' @param
#' @return
#' @export
#'



removeOutliers <- function(myInitialFactorizedData, numOfSDsToInclue){

  lossLogSD <- sd(myInitialFactorizedData$myDatasetLog$loss)
  lossLogMean <- mean(myInitialFactorizedData$myDatasetLog$loss)

  myDatasetNoOutliers <- myInitialFactorizedData$myDataset %>%
    filter(loss >= exp(lossLogMean - numOfSDsToInclue*lossLogSD) & loss <= exp(lossLogMean + numOfSDsToInclue*lossLogSD))

  myDatasetLogNoOutliers <- myInitialFactorizedData$myDatasetLog %>%
    filter(loss >= lossLogMean - numOfSDsToInclue*lossLogSD & loss <= lossLogMean + numOfSDsToInclue*lossLogSD )

  listToReturn <- list(myDatasetNoOutliers$id, myDatasetLogNoOutliers$id)
  names(listToReturn) <- c("idxNoOut", "IdxNoOutLog")

  return(listToReturn)

}

