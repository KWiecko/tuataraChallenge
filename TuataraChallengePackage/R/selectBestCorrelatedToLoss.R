#'
#'
#'
#' @param
#' @return
#' @export
#'

selectBestCorrelatedToLoss <- function(inputDataFrame, corrTreshold){

  corTestVect <- c()
  #leadLag <- 10


  for(colname in colnames(inputDataFrame[, !(colnames(inputDataFrame) %in% c("id", "loss"))])){



    corTestVect <- c(corTestVect,

                     cor( unlist(
                       inputDataFrame[, (colnames(inputDataFrame) %in% paste0(colname))]
                     ),
                     inputDataFrame$loss,
                     method = "spearman")

    ) %>%
      abs()
  }

  corTestDF <- data.frame(corTestVect, colnames(inputDataFrame[, !(colnames(inputDataFrame) %in% c("id", "loss"))])) %>%
    arrange(desc(corTestVect))
  names(corTestDF) <- c("corToLoss","colName")

  corTestDF <- corTestDF %>%
    filter(corToLoss >= corrTreshold)

  return(corTestDF)

}
