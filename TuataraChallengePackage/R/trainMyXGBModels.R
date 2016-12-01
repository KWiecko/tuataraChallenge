#'
#'
#'
#' @param
#' @return
#' @export
#'
#'

trainMyXGBModels <- function(sc, trainCase1CorrToLoss, treeDepth, subsetSize ,isLossLog){

  library(sparklyr)
  library(caret)
  library(dplyr)

  # Training GLM and XGB on this dataset
  # subseting data
  trainCase1CorrToLossFinal_subset <- getCaretDataSample(trainCase1CorrToLoss,
                                                         trainCase1CorrToLoss$loss
                                                         , subsetSize, 1, 1)
  trainCase1CorrToLossFinal_subset <- trainCase1CorrToLossFinal_subset$Resample1

  testCase1CorrToLossFinal_subset <- getCaretDataSample(trainCase1CorrToLoss[!(trainCase1CorrToLoss$id %in% trainCase1CorrToLossFinal_subset$id),],
                                                        trainCase1CorrToLoss[!(trainCase1CorrToLoss$id %in% trainCase1CorrToLossFinal_subset$id), ]$loss,
                                                        20000, 1, 2)
  testCase1CorrToLossFinal_subset <- testCase1CorrToLossFinal_subset$Resample1

  nObsCorrToLoss <- length(unlist(testCase1CorrToLossFinal_subset[,1]))
  nPredCorrToLoss <- length(colnames(testCase1CorrToLossFinal_subset)) - 2

  # sending data to spark
  trainCase1CorrToLossFinal_subset_tbl <- copy_to(sc, trainCase1CorrToLossFinal_subset, "trainCase1CorrToLoss", overwrite = TRUE)
  testCase1CorrToLossFinal_subset_tbl <- testCase1CorrToLossFinal_subset %>%
    select(-loss) %>%
    copy_to(sc, ., "testCase1CorrToLoss", overwrite = TRUE)
  #                               training                      testing
  datasets <- list(trainCase1CorrToLossFinal_subset, testCase1CorrToLossFinal_subset)
  names(datasets) <- c("trn", "tst")



  # Training XGB model in spark
  # max depth set to 2
  trainCase1CorrToLossXGB <- trainCase1CorrToLossFinal_subset_tbl %>%
    select(-id) %>%
    ml_gradient_boosted_trees(loss ~., type = "regression", max.depth = treeDepth)



  trainCase1CorrToLossPredictionsXGB_test <- select(testCase1CorrToLossFinal_subset_tbl , -id) %>%
    sdf_predict(trainCase1CorrToLossXGB, .) %>%
    collect()

  adjRsqCorrToLossXGB2 <- adjRsq(testCase1CorrToLossFinal_subset, trainCase1CorrToLossPredictionsXGB_test, nObsCorrToLoss, nPredCorrToLoss, isLossLog)

  #                           model                     predictions                               R sq adj
  mod1_xgb <- list(trainCase1CorrToLossXGB, trainCase1CorrToLossPredictionsXGB_test, adjRsqCorrToLossXGB2)
  names(mod1_xgb) <- c("model", "predDF", "RsqAdj")


  xgbMods <- list(mod1_xgb)
  names(xgbMods) <- c("mod1")

  models <- list(xgbMods)
  names(models) <- c("XGB")

  listToReturn <- list(models, datasets)
  names(listToReturn) <- c("models", "datasets")

  return(listToReturn)

}
