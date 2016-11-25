#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'
#'

trainMyModels <- function(sc, trainCase1CorrToLoss, isLossLog){

  library(sparklyr)
  library(caret)
  library(dplyr)

  # Training GLM and XGB on this dataset
  # subseting data
  trainCase1CorrToLossFinal_subset <- getCaretDataSample(trainCase1CorrToLoss, trainCase1CorrToLoss$loss, 50000, 1, 1)
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

  # Training GLM model in spark

  trainCase1CorrToLossGLM <- trainCase1CorrToLossFinal_subset_tbl %>%
    select(-id) %>%
    ml_generalized_linear_regression(loss ~.)

  bestCorrAIC <- trainCase1CorrToLossGLM$aic

  trainCase1CorrToLossPredictionsGLM_train <- select(trainCase1CorrToLossFinal_subset_tbl, -id) %>%
    select(-loss) %>%
    sdf_predict(trainCase1CorrToLossGLM, .) %>%
    collect()

  trainCase1CorrToLossPredictionsGLM_test <- select(testCase1CorrToLossFinal_subset_tbl , -id) %>%
    sdf_predict(trainCase1CorrToLossGLM, .) %>%
    collect()

  adjRsqCorrToLossGLM <- adjRsq(testCase1CorrToLossFinal_subset, trainCase1CorrToLossPredictionsGLM_test, nObsCorrToLoss, nPredCorrToLoss, isLossLog)

  #                           model                     predictions                           R sq adj
  mod1_glm <- list(trainCase1CorrToLossGLM, trainCase1CorrToLossPredictionsGLM_test, adjRsqCorrToLossGLM)
  names(mod1_glm) <- c("model", "predDF", "RsqAdj")

  # Training XGB model in spark
  # max depth set to 2
  trainCase1CorrToLossXGB_2 <- trainCase1CorrToLossFinal_subset_tbl %>%
    select(-id) %>%
    ml_gradient_boosted_trees(loss ~., type = "regression", max.depth = 2)

  trainCase1CorrToLossXGB_5 <- trainCase1CorrToLossFinal_subset_tbl %>%
    select(-id) %>%
    ml_gradient_boosted_trees(loss ~., type = "regression", max.depth = 5)

  trainCase1CorrToLossXGB_10 <- trainCase1CorrToLossFinal_subset_tbl %>%
    select(-id) %>%
    ml_gradient_boosted_trees(loss ~., type = "regression", max.depth = 10)

  trainCase1CorrToLossXGB_15 <- trainCase1CorrToLossFinal_subset_tbl %>%
    select(-id) %>%
    ml_gradient_boosted_trees(loss ~., type = "regression", max.depth = 15)


  trainCase1CorrToLossPredictionsXGB_2_test <- select(testCase1CorrToLossFinal_subset_tbl , -id) %>%
    sdf_predict(trainCase1CorrToLossXGB_2, .) %>%
    collect()

  adjRsqCorrToLossXGB2 <- adjRsq(testCase1CorrToLossFinal_subset, trainCase1CorrToLossPredictionsXGB_2_test, nObsCorrToLoss, nPredCorrToLoss, isLossLog)

  #                           model                     predictions                               R sq adj
  mod1_xgb <- list(trainCase1CorrToLossXGB_2, trainCase1CorrToLossPredictionsXGB_2_test, adjRsqCorrToLossXGB2)
  names(mod1_xgb) <- c("model", "predDF", "RsqAdj")

  trainCase1CorrToLossPredictionsXGB_5_test <- select(testCase1CorrToLossFinal_subset_tbl , -id) %>%
    sdf_predict(trainCase1CorrToLossXGB_5, .) %>%
    collect()

  adjRsqCorrToLossXGB5 <- adjRsq(testCase1CorrToLossFinal_subset, trainCase1CorrToLossPredictionsXGB_5_test, nObsCorrToLoss, nPredCorrToLoss, isLossLog)

  #                           model                     predictions                               R sq adj
  mod2_xgb <- list(trainCase1CorrToLossXGB_5, trainCase1CorrToLossPredictionsXGB_5_test, adjRsqCorrToLossXGB5)
  names(mod2_xgb) <- c("model", "predDF", "RsqAdj")

  trainCase1CorrToLossPredictionsXGB_10_test <- select(testCase1CorrToLossFinal_subset_tbl , -id) %>%
    sdf_predict(trainCase1CorrToLossXGB_10, .) %>%
    collect()

  adjRsqCorrToLossXGB10 <- adjRsq(testCase1CorrToLossFinal_subset, trainCase1CorrToLossPredictionsXGB_10_test, nObsCorrToLoss, nPredCorrToLoss, isLossLog)

  #                           model                     predictions                               R sq adj
  mod3_xgb <- list(trainCase1CorrToLossXGB_10, trainCase1CorrToLossPredictionsXGB_10_test, adjRsqCorrToLossXGB10)
  names(mod3_xgb) <- c("model", "predDF", "RsqAdj")

  trainCase1CorrToLossPredictionsXGB_15_test <- select(testCase1CorrToLossFinal_subset_tbl , -id) %>%
    sdf_predict(trainCase1CorrToLossXGB_15, .) %>%
    collect()

  adjRsqCorrToLossXGB15 <- adjRsq(testCase1CorrToLossFinal_subset, trainCase1CorrToLossPredictionsXGB_15_test, nObsCorrToLoss, nPredCorrToLoss, isLossLog)

  #                           model                     predictions                               R sq adj
  mod4_xgb <- list(trainCase1CorrToLossXGB_15, trainCase1CorrToLossPredictionsXGB_15_test, adjRsqCorrToLossXGB15)
  names(mod4_xgb) <- c("model", "predDF", "RsqAdj")

  glmMods <- list(mod1_glm)
  names(glmMods) <- c("mod1")

  xgbMods <- list(mod1_xgb, mod2_xgb, mod3_xgb, mod4_xgb)
  names(xgbMods) <- c("mod1", "mod2", "mod3", "mod4")

  models <- list(glmMods, xgbMods)
  names(models) <- c("GLM", "XGB")

  listToReturn <- list(models, datasets)
  names(listToReturn) <- c("models", "datasets")

  return(listToReturn)

}
