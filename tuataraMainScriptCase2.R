# working script
library(sparklyr)
library(dplyr)
library(devtools)
library(roxygen2)
library(TuataraChallengePackage)

requiredPackages <- packageInstaller()

# # # # # # # # # # # # # # # # # # # #
# setting env varjust in case - may vary depending on system
Sys.setenv(SPARK_HOME = "/usr/local/spark")
# connecting to spark
sc <- spark_connect(master = "spark://hadoopmasternode:7077")


myDataList <- readInitialDataFromHDFS(sc)



myInitialFactorizedData <- factorizeMyDataset(myDataList, "train", "case2")

trainIdxsWithoutOutliers <- removeOutliers(myInitialFactorizedData, 2)

# Initial Machine learning on Spark
#### GLM case
###### Trying to get best columns for GLM
######### Calculated correlation picked columns:
######### Selecting variables that have significant correlation with 'loss' variable
          #normal dataset
          trainCase2SignifCorr <- significantCorrelationSelector(myInitialFactorizedData$myDataset)
          
          # dataset where loss = log(loss)
          trainCase2SignifCorrLog <- significantCorrelationSelector(myInitialFactorizedData$myDatasetLog)
          

######### Selecting most correlated vars with 'loss' and least with each other
          #normal dataset
          bestCorrelatedColsToLoss <- selectBestCorrelatedToLoss(trainCase2SignifCorr, 0.1)
          trainCase2CorrToLoss <- trainCase2SignifCorr[, colnames(trainCase2SignifCorr) %in% c(as.character(bestCorrelatedColsToLoss$colName), "id", "loss")]
          
          case2CorrToLoss <- trainMyModels(sc, trainCase2CorrToLoss, FALSE, trainIdxsWithoutOutliers, FALSE, FALSE)
          
          
          # dataset where loss = log(loss)
          bestCorrelatedColsToLossLog <- selectBestCorrelatedToLoss(trainCase2SignifCorrLog, 0.1)
          trainCase2CorrToLossLog <- trainCase2SignifCorrLog[, colnames(trainCase2SignifCorrLog) %in% c(as.character(bestCorrelatedColsToLossLog$colName), "id", "loss")]
          
          case2CorrToLossLog <-  trainMyModels(sc, trainCase2CorrToLossLog, TRUE, trainIdxsWithoutOutliers, FALSE, FALSE)
          
          # selectWeakCorrelatedColumns( dataset, number of columns that are best correlated with 'loss' to omit, correlation treshold for columns)
          #normal dataset
          trainCase2WeakCorr <- selectWeakCorrelatedColumns(trainCase1SignifCorr, 1, 0.15)
          
          case2WeakCorr <-  trainMyModels(sc, trainCase2WeakCorr, FALSE, trainIdxsWithoutOutliers, FALSE, FALSE)
          
          # dataset where loss = log(loss)
          trainCase2WeakCorrLog <- selectWeakCorrelatedColumns(trainCase1SignifCorrLog, 1, 0.15)
          
          case2WeakCorrLog <-  trainMyModels(sc, trainCase2WeakCorrLog, TRUE, trainIdxsWithoutOutliers, FALSE, FALSE)

