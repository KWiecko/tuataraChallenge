#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'

packageInstaller <- function(){

  requiredPackages <- c("car", "nortest", "fBasics", "Hmisc",
                        "corrplot", "corrgram", "PerformanceAnalytics",
                        "jmuOutlier", "PairedData", "energy",
                        "corrr", "purrr", "fpc", "dplyr", "sparklyr")
  installedPacks <- installed.packages()[,1]
  for(package in requiredPackages) {
    if (sum(grepl(pattern = paste0(package), installedPacks)) !=0){
      next
    } else {
      install.packages(paste0(package))
      installedPacks <- installed.packages()[,1]
    }
  }

  return(requiredPackages)
}
