#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'

selectBestCorrelatedToLoss <- function(inputDataFrame){

  corTestVect <- c()
  #leadLag <- 10
  #corrTreshold <- 0.15

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
    filter(corToLoss >= 0.1)

  return(corTestDF)

}
