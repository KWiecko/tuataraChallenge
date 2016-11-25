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

# # # # # # # # # # # # # # # # # # # #
# readDataFromHDFS() output
## list structure
## List[[1]] <- spark connection object
## List[[2]] <- training data from HDFS
## List[[3]] <- testing data from HDFS

myDataList <- readInitialDataFromHDFS(sc)


# # # # # # # # # # # # # # # # # # # #
## collecting data for data manipulation activities

# myTrnDataset <- collect(myDataList[[2]])
# myTestDataset <- collect(myDataList[[3]])

## factorizeMyDataset()
##  Initial data manipulation explained in the factorizeMyDataset()'s code comments 
## arguments:
## - list with initial datasets and spark connection object
## - "train"/"test" string indicating which dataset should be factorized

myInitialFactorizedData <- factorizeMyDataset(myDataList, "train", "case2")
##
## returns:
## 
## List[[1]] <- spark connection object
## List[[2]] <- training data from HDFS -> letters converted to ints
## List[[3]] <- testing data from HDFS -> letters converted to ints

# # # # # # # # # # # # # # # # # # # #

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
          bestCorrelatedColsToLoss <- selectBestCorrelatedToLoss(trainCase2SignifCorr)
          trainCase2CorrToLoss <- trainCase2SignifCorr[, colnames(trainCase2SignifCorr) %in% c(as.character(bestCorrelatedColsToLoss$colName), "id", "loss")]
          
          case2CorrToLoss <- trainMyModels(sc, trainCase2CorrToLoss, FALSE)
          
          
          # dataset where loss = log(loss)
          bestCorrelatedColsToLossLog <- selectBestCorrelatedToLoss(trainCase2SignifCorrLog)
          trainCase2CorrToLossLog <- trainCase2SignifCorrLog[, colnames(trainCase2SignifCorrLog) %in% c(as.character(bestCorrelatedColsToLossLog$colName), "id", "loss")]
          
          case2CorrToLossLog <-  trainMyModels(sc, trainCase2CorrToLossLog, TRUE)
          
          # selectWeakCorrelatedColumns( dataset, number of columns that are best correlated with 'loss' to omit, correlation treshold for columns)
          #normal dataset
          trainCase2WeakCorr <- selectWeakCorrelatedColumns(trainCase1SignifCorr, 1, 0.15)
          
          case2WeakCorr <-  trainMyModels(sc, trainCase2WeakCorr, FALSE)
          
          # dataset where loss = log(loss)
          trainCase2WeakCorrLog <- selectWeakCorrelatedColumns(trainCase1SignifCorrLog, 1, 0.15)
          
          case2WeakCorrLog <-  trainMyModels(sc, trainCase2WeakCorrLog, TRUE)

