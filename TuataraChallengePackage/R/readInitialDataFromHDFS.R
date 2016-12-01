#'
#'
#'
#' @param
#' @return
#' @export
readInitialDataFromHDFS <- function(sc){
# setting env varjust in case - may vary depending on system
Sys.setenv(SPARK_HOME = "/usr/local/spark")

#loading rquired packages
library(TuataraChallengePackage)
library(sparklyr)
library(dplyr)


#connecting
#sc <- spark_connect(master = "yarn-client")

#loading data from kaggle to hdfs
#done via flume

#loading training dataset to hdfs
myTrnDataset <- spark_read_csv(sc, "myTrnData", "/konrad/tuatara/myTrnData/myTrnData")

#loading testing dataset to hdfs
myTstDataset <- spark_read_csv(sc, "myTstData", "/konrad/tuatara/myTstData/myTstData")

listToReturn <- list(sc, myTrnDataset, myTstDataset)
names(listToReturn) <- c("connectionObj", "myTrnDataset", "myTstDataset")
return(listToReturn)
}
