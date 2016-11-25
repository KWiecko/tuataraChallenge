# working script
library(sparklyr)
library(dplyr)
library(devtools)
library(roxygen2)
library(TuataraChallengePackage)
library(glmnet)
# ridge regression

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

myInitialFactorizedData <- factorizeMyDataset(myDataList, "train", "case1")

## creating a ridge regression model for normal dataset

case1RidgeModelNormalSet <- myInitialFactorizedData$myDataset

case1RidgeModelNormalSet <- getCaretDataSample(case1RidgeModelNormalSet, case1RidgeModelNormalSet$loss, 50000, 1, 1)
case1RidgeModelNormalSet <- case1RidgeModelNormalSet$Resample1 

for(q in 2:(length(colnames(case1RidgeModelNormalSet)) - 1)){
  case1RidgeModelNormalSet[, q] <- case1RidgeModelNormalSet[, q]/sd(case1RidgeModelNormalSet[, q] %>% unlist() %>% as.vector())
}

case1RidgeModelNormalSet_test <- getCaretDataSample(myInitialFactorizedData$myDataset[!(myInitialFactorizedData$myDataset$id %in% case1RidgeModelNormalSet$id),],
                                                    myInitialFactorizedData$myDataset[!(myInitialFactorizedData$myDataset$id %in% case1RidgeModelNormalSet$id), ]$loss,
                                                      20000, 1, 2)
case1RidgeModelNormalSet_test <- case1RidgeModelNormalSet_test$Resample1

for(q in 2:(length(colnames(case1RidgeModelNormalSet_test)) - 1)){
  case1RidgeModelNormalSet_test[, q] <- case1RidgeModelNormalSet_test[, q]/sd(case1RidgeModelNormalSet_test[, q] %>% unlist() %>% as.vector())
}






x = model.matrix(loss ~.-1, data = case1RidgeModelNormalSet[,-1])
y = case1RidgeModelNormalSet$loss 

# wystarczy ze obiekt jest odpowiedniej klasy
xTest <- model.matrix(loss ~.-1, data = case1RidgeModelNormalSet_test[,-1])
yTest <- case1RidgeModelNormalSet_test$loss


fit.ridge = glmnet(x, y, alpha = 0)
plot(fit.ridge, xvar="lambda", label = TRUE)
plot(fit.ridge, xvar="dev", label = TRUE)
cv.ridge = cv.glmnet(x, y, alpha = 0)
plot(cv.ridge)

## creating a lasso regression model for normal dataset
fit.lasso=glmnet(x,y)
plot(fit.lasso, xvar="lambda", label = TRUE)
plot(fit.lasso, xvar="dev", label = TRUE)
cv.lasso = cv.glmnet(x, y)
plot(cv.lasso)
coef(cv.lasso)

lasso.tr = glmnet(x, y)
lasso.tr
lasso.pred = predict(lasso.tr, xTest)
plot(lasso.tr, xvar="lambda", label = TRUE)
plot(lasso.tr, xvar="dev", label = TRUE)
rmse = sqrt(apply((yTest - lasso.pred)^2, 2, mean))
plot(log(lasso.tr$lambda), rmse, type="b", xlab = "Log(lambda)")
lam.best.non.log=lasso.tr$lambda[order(rmse)[1]]
lam.best.non.log
coef(lasso.tr, s=lam.best.non.log)


## creating a ridge regression model for log dataset

case1RidgeModelLogSet <-case1RidgeModelNormalSet %>% mutate(loss = log(loss))
case1RidgeModelLogSet_test <-case1RidgeModelNormalSet_test %>% mutate(loss = log(loss))




x = model.matrix(loss ~.-1, data = case1RidgeModelLogSet[,-1])
y = case1RidgeModelLogSet$loss 

# wystarczy ze obiekt jest odpowiedniej klasy
xTest <- model.matrix(loss ~.-1, data = case1RidgeModelLogSet_test[,-1])
yTest <- case1RidgeModelLogSet_test$loss


fit.ridge = glmnet(x, y, alpha = 0)
plot(fit.ridge, xvar="lambda", label = TRUE)
plot(fit.ridge, xvar="dev", label = TRUE)
cv.ridge = cv.glmnet(x, y, alpha = 0)
plot(cv.ridge)

## creating a lasso regression model for log dataset
fit.lasso=glmnet(x,y)
plot(fit.lasso, xvar="lambda", label = TRUE)
plot(fit.lasso, xvar="dev", label = TRUE)
cv.lasso = cv.glmnet(x, y)
plot(cv.lasso)
coef(cv.lasso)

lasso.tr = glmnet(x, y)
lasso.tr
lasso.pred = predict(lasso.tr, xTest)
plot(lasso.tr, xvar="lambda", label = TRUE)
plot(lasso.tr, xvar="dev", label = TRUE)
rmse = sqrt(apply((exp(yTest) - exp(lasso.pred))^2, 2, mean))
plot(log(lasso.tr$lambda), rmse, type="b", xlab = "Log(lambda)")
lam.best.log=lasso.tr$lambda[order(rmse)[1]]
lam.best.log
coef(lasso.tr, s=lam.best.log)



