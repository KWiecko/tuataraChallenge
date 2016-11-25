#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'


significantCorrelationSelector <- function(inputDataset){

  corTestVect <- c()

  for(colname in colnames(inputDataset[, !(colnames(inputDataset) %in% c("id", "loss"))])){

    corTestVect <- c(corTestVect,
                     ifelse(cor.test( unlist(
                       inputDataset[, (colnames(inputDataset) %in% paste0(colname))]
                     ),
                     inputDataset$loss,
                     method = "spearman")$p.value >= 0.05, 0, 1)
    )
  }


  signifCorrCols <- data.frame(colnames(inputDataset[, !(colnames(inputDataset) %in% c("id", "loss"))]),
                               corTestVect) %>% filter(corTestVect ==1)
  names(signifCorrCols) <- c("signifCorrColsName", "isSignif")
  datasetToReturn <- signifCorrCols %>%
                     select(signifCorrColsName) %>%
                     unlist() %>%
                     as.vector() %>%
                     paste0("^",., "$", collapse = "|") %>%
                     grep(pattern = ., colnames(inputDataset)) %>%
                     select(inputDataset,id, ., loss)
return(datasetToReturn)

}
