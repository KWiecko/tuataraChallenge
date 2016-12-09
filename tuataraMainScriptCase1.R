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


myInitialFactorizedData <- factorizeMyDataset(myDataList, "train", "case1")

trainIdxsWithoutOutliers <- removeOutliers(myInitialFactorizedData, 2)


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
          bestCorrelatedColsToLoss <- selectBestCorrelatedToLoss(trainCase1SignifCorr, 0.1)
          trainCase1CorrToLoss <- trainCase1SignifCorr[, colnames(trainCase1SignifCorr) %in% c(as.character(bestCorrelatedColsToLoss$colName), "id", "loss")]
          
          #trainMyModels <- function(sc, trainCase1CorrToLoss ,isLossLog, noOutliersIdxs, omitOutliersforTest, omitOutliersforTrain)
          case1CorrToLoss <- trainMyModels(sc, trainCase1CorrToLoss, FALSE, trainIdxsWithoutOutliers, FALSE, FALSE)
          
          
          # dataset where loss = log(loss)
          bestCorrelatedColsToLossLog <- selectBestCorrelatedToLoss(trainCase1SignifCorrLog, 0.1)
          trainCase1CorrToLossLog <- trainCase1SignifCorrLog[, colnames(trainCase1SignifCorrLog) %in% c(as.character(bestCorrelatedColsToLossLog$colName), "id", "loss")]
          
          case1CorrToLossLog <-  trainMyModels(sc, trainCase1CorrToLossLog, TRUE, trainIdxsWithoutOutliers, FALSE, FALSE)
          
          # selectWeakCorrelatedColumns( dataset, number of columns that are best correlated with 'loss' to omit, correlation treshold for columns)
          #normal dataset
          trainCase1WeakCorr <- selectWeakCorrelatedColumns(trainCase1SignifCorr, 1, 0.15)
          
          case1WeakCorr <-  trainMyModels(sc, trainCase1WeakCorr, FALSE, trainIdxsWithoutOutliers, FALSE, FALSE)
          
          # dataset where loss = log(loss)
          trainCase1WeakCorrLog <- selectWeakCorrelatedColumns(trainCase1SignifCorrLog, 1, 0.15)
          
          case1WeakCorrLog <-  trainMyModels(sc, trainCase1WeakCorrLog, TRUE, trainIdxsWithoutOutliers, FALSE, FALSE)

          # TESTING
          
          myInitialFactorizedDataTest <- factorizeMyDataset(myDataList, "test", "case1")
          myInitialFactorizedDataTest <- myInitialFactorizedDataTest$myDataset 
          myInitialFactorizedDataTest <- myInitialFactorizedDataTest[, colnames(myInitialFactorizedDataTest) %in% c(as.character(bestCorrelatedColsToLoss$colName), "id")]
          myInitialFactorizedDataTest_tbl <- copy_to(sc, myInitialFactorizedDataTest, 'propperTest')
          
          kagglePred <- select(myInitialFactorizedDataTest_tbl, -id) %>%
            sdf_predict(case1CorrToLoss$models$XGB$mod2$model, .) %>%
            collect()
          
          kagglePred <- kagglePred %>%
            select(prediction)
          
          kagglePred <- cbind(myInitialFactorizedDataTest$id, kagglePred)
          names(kagglePred) <- c("id", "loss")
          library(readr)
          write_csv(kagglePred, "submission1.csv")
          


