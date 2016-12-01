# working script
library(sparklyr)
library(dplyr)
library(devtools)
library(roxygen2)
library(TuataraChallengePackage)


# # # # # # # # # # # # # # # # # # # #
# setting env varjust in case - may vary depending on system
Sys.setenv(SPARK_HOME = "/usr/local/spark")
# connecting to spark
sc <- spark_connect(master = "spark://hadoopmasternode:7077")

myDataList <- readInitialDataFromHDFS(sc)

myInitialFactorizedData <- factorizeMyDataset(myDataList, "train", "case1")

# trainMyXGBModels <- function(sc, dataset, treeDepth, subsetSize ,isLossLog)
# trainMyModels <- function(sc, trainCase1CorrToLoss ,isLossLog, noOutliersIdxs, omitOutliersforTest, omitOutliersforTrain)
allColsXGB <- trainMyXGBModels(sc, myInitialFactorizedData$myDataset, 5, 20000, FALSE)
allColsXGBLog <- trainMyXGBModels(sc, myInitialFactorizedData$myDataset, 5, 20000, TRUE)



