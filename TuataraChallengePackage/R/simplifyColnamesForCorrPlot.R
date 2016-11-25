#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'

simplifyColnamesForCorrPlot <- function(colnamesInputDatasetMatrix){

  newColNames <- gsub(pattern = "cont", replacement = "c", colnamesInputDatasetMatrix) %>%
    gsub(pattern = "cat", replacement = "", .)

  return(newColNames)

}
