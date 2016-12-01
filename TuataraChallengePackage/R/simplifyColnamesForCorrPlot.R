#'
#'
#'
#' @param
#' @return
#' @export
#'

simplifyColnamesForCorrPlot <- function(colnamesInputDatasetMatrix){

  newColNames <- gsub(pattern = "cont", replacement = "c", colnamesInputDatasetMatrix) %>%
    gsub(pattern = "cat", replacement = "", .)

  return(newColNames)

}
