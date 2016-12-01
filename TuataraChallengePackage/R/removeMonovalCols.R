#'
#'
#'
#' @param
#' @return
#' @export
#'


# Deselecting columns with very monolithical structure

removeMonovalCols <- function(inputDataframe){

  library(dplyr)

  idxToRemove <- c()

  for(count in 2:(length(colnames(inputDataframe)) - 1 ) ){

    if(length(levels(factor(inputDataframe[,count] %>% unlist() %>% as.vector()))) <= 2){

      transferVect <- inputDataframe[,count] %>% unlist() %>% as.vector()
      fractOfAppear <- length(transferVect[transferVect == as.integer(levels(factor(inputDataframe[count] %>% unlist() %>% as.vector))[1])])/length(transferVect)


      if(fractOfAppear > 0.99 || fractOfAppear < 0.01){

        idxToRemove <- c(idxToRemove, count)
      }
    }
  }

  inputDataframe <- inputDataframe[, -idxToRemove]

  return(inputDataframe)
}
