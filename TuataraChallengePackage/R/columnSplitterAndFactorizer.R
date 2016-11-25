#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'
#'


columnSplitterAndFactorizer <- function(datasetToFactorize){

  # getting columns to factorize
    columnsToFactorize <- datasetToFactorize %>%
    select(contains("cat")) %>%
    colnames()

    columnsToDelete <- c()
    columnsToAdd <- data.frame()

    for(colIdx in 2:(length(columnsToFactorize)+1)){
      #progress
      print(paste0("Dataset split and factorized in ", round(100 * colIdx/(length(columnsToFactorize) + 1), 2) , "%"))

      currColName <- colnames(datasetToFactorize[, colIdx])
      workColumn <- datasetToFactorize[, colIdx]
      names(workColumn) <- c("originalCol")

      if(levels(factor(datasetToFactorize[, colIdx] %>% unlist() %>% as.vector)) %>% length()>2){

        newColsCharVals <- levels(factor(datasetToFactorize[, colIdx] %>% unlist() %>% as.vector))[1:(length(levels(factor(datasetToFactorize[, colIdx] %>% unlist() %>% as.vector)))-1)]

        #newCols <- data.frame()

          for(newColsCharValsIdx in 1:length(newColsCharVals)){
          # for every level the 0-1 column is created -> newCol

            newCol <- workColumn %>%
                      mutate(originalCol = ifelse(originalCol == paste0(newColsCharVals[newColsCharValsIdx]), 1, 0)) %>%
                      unlist() %>%
                      as.vector() %>%
                      as.integer() %>%
                      as.data.frame()

            names(newCol) <- paste0(currColName,"_" ,newColsCharVals[newColsCharValsIdx])
            # newCols dataset is created by combining newCols df with each newCol
                if(newColsCharValsIdx == 1){
                  newCols <- data.frame(newCol)
                }else{
                  newCols <- data.frame(newCols, newCol)
                }
          }
        # the old column with 3+ levels is removed from dataset

        columnsToDelete <- c(columnsToDelete, colIdx)
        # the newCols dataset is added to DF

        if (length(names(columnsToAdd)) == 0){
          columnsToAdd <- newCols
        }else{
          columnsToAdd <- cbind(columnsToAdd, newCols)
        }




      } else{


        datasetToFactorize[, colIdx] <- workColumn %>%
                                          mutate(originalCol = ifelse(originalCol == paste0(levels(factor(datasetToFactorize[, colIdx] %>% unlist() %>% as.vector))[1]),
                                                                    0,
                                                                    1)) %>%
                                          unlist() %>%
                                          as.vector() %>%
                                          as.integer()

      }

    }
    datasetToFactorize <- datasetToFactorize[, -columnsToDelete]
    datasetToFactorize <- cbind(datasetToFactorize, columnsToAdd)

  return(datasetToFactorize);
}
