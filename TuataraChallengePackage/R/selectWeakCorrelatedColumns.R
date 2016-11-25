#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'

selectWeakCorrelatedColumns <- function(inputDataFrame, leadLag, corrTreshold){
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

  #printing 3 best correlated columns
  for(i in 1:3) print(corTestDF$colName[i])


  corTestDF <- corTestDF[leadLag:length(corTestDF$colName),]

  corToSingleVar <- c()

  bestCorrIdx <- 1
  selectedCols <- c()
  isNextCol <- TRUE

  while(isNextCol){
    corrTestOthersToBestVect <- c()
    corrOthersToBestVect <- c()
    selectedCols <- c(selectedCols, as.character(corTestDF$colName[1]))

    for(colname in corTestDF$colName[-1]){
      corrOthersToBestVect <- c(corrOthersToBestVect,
                                cor(
                                  unlist(
                                    inputDataFrame[, grep(pattern = paste0("^",corTestDF$colName[bestCorrIdx], "$"), colnames(inputDataFrame))]
                                  ),
                                  unlist(
                                    inputDataFrame[, grep(pattern = paste0("^",colname,"$"), colnames(inputDataFrame))]

                                  ),
                                  method = "spearman"
                                )
      ) %>% abs()

      corrTestOthersToBestVect <- c(corrTestOthersToBestVect,
                                    ifelse(cor.test(
                                      unlist(
                                        inputDataFrame[, grep(pattern = paste0("^",corTestDF$colName[bestCorrIdx], "$"), colnames(inputDataFrame))]
                                      ),
                                      unlist(
                                        inputDataFrame[, grep(pattern = paste0("^",colname,"$"), colnames(inputDataFrame))]
                                      ),
                                      method = "spearman")$p.value >= 0.05, 0, 1 )
      )

    }
    corrToBestDF <- data.frame(corTestDF$colName[-1], corrOthersToBestVect, corrTestOthersToBestVect)
    names(corrToBestDF) <- c("varName", "varCorrToBest", "varCorrSignif")
    corrToBestDF <- corrToBestDF %>% mutate(varCorrToBest = ifelse(varCorrSignif == 0, 0, varCorrToBest))
    nonCorrelatedToBest <- corrToBestDF %>% filter(varCorrToBest <= corrTreshold)

    corTestDF <- corTestDF %>% filter(colName %in% nonCorrelatedToBest$varName)

    if(length(corTestDF$colName) > 1){
      isNextCol <- TRUE
    }else if (length(corTestDF$colName) == 1){
      isNextCol <- FALSE
      selectedCols <- c(selectedCols, as.character(corTestDF$colName[1]))
    }else{
      isNextCol <- FALSE
    }

  }
  selectedCols <- c("id", selectedCols,"loss")


  inputDataFrame  <-  inputDataFrame[, colnames(inputDataFrame) %in% selectedCols]

}
