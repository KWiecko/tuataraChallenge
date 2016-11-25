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

myInitialFactorizedData <- factorizeMyDataset(myDataList, "train", "case1")
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
          trainCase1SignifCorr <- significantCorrelationSelector(myInitialFactorizedData$myDataset)
          
          # dataset where loss = log(loss)
          trainCase1SignifCorrLog <- significantCorrelationSelector(myInitialFactorizedData$myDatasetLog)
          

######### Selecting most correlated vars with 'loss' and least with each other
          #normal dataset
          bestCorrelatedColsToLoss <- selectBestCorrelatedToLoss(trainCase1SignifCorr)
          trainCase1CorrToLoss <- trainCase1SignifCorr[, colnames(trainCase1SignifCorr) %in% c(as.character(bestCorrelatedColsToLoss$colName), "id", "loss")]
          
          case1CorrToLoss <- trainMyModels(sc, trainCase1CorrToLoss, FALSE)
          
          
          # dataset where loss = log(loss)
          bestCorrelatedColsToLossLog <- selectBestCorrelatedToLoss(trainCase1SignifCorrLog)
          trainCase1CorrToLossLog <- trainCase1SignifCorrLog[, colnames(trainCase1SignifCorrLog) %in% c(as.character(bestCorrelatedColsToLossLog$colName), "id", "loss")]
          
          case1CorrToLossLog <-  trainMyModels(sc, trainCase1CorrToLossLog, TRUE)
          
          # selectWeakCorrelatedColumns( dataset, number of columns that are best correlated with 'loss' to omit, correlation treshold for columns)
          #normal dataset
          trainCase1WeakCorr <- selectWeakCorrelatedColumns(trainCase1SignifCorr, 1, 0.15)
          
          case1WeakCorr <-  trainMyModels(sc, trainCase1WeakCorr, FALSE)
          
          # dataset where loss = log(loss)
          trainCase1WeakCorrLog <- selectWeakCorrelatedColumns(trainCase1SignifCorrLog, 1, 0.15)
          
          case1WeakCorrLog <-  trainMyModels(sc, trainCase1WeakCorrLog, TRUE)

          


