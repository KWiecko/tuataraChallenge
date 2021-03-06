#'
#'
#'
#' @param
#' @return
#' @export
#'

factorizeMyDataset <- function(inputList, setToFactorize, caseOfFactorization){

# factorizeMyDataset (SparkConnection obj, kaggle training dataset in HDFS reference, kaggle training dataset in HDFS reference, case name (f.e. "case1"))

  #loading rquired packages
    library(sparklyr)
    library(dplyr)
    library(TuataraChallengePackage)

  if(setToFactorize == "train"){
    datasetToFactorize <- collect(inputList[[2]])
  }else{
    datasetToFactorize <- collect(inputList[[3]])
  }

# creating 3 factorized datasets:
# 1. where plain factor function is applied to every categorical column,
# 2. where there is a data sctucture conserved (f.e. A = 1, B = 2, ...),
# 3. where the columns always have 0-1 values and those that have over 2 levels are split accordingly

  # creating preliminary dataset list to return to user
  ##
  ## list[[1]] Sparklyr connection object
  ##
  ## list[[2]] element: required (train or test) case 1. datasets:
  ##                                  - loss = loss
  ##                                  - loss = log(loss)
  ## list[[3]] element: required (train or test) case 2. datasets:
  ##                                  - loss = loss
  ##                                  - loss = log(loss)
  ## list[[4]] element: required (train or test) case 3. datasets:
  ##                                  - loss = loss
  ##                                  - loss = log(loss)



# executing factorization
# case 1.
  #
  if(caseOfFactorization == "case1"){
    myTrnDataset1 <- simpleFactorizer(datasetToFactorize)
    if(setToFactorize == "train"){
      myTrnDatasetLog1 <- myTrnDataset1 %>% mutate(loss = log(loss))
      listOfDatasetsToReturn <- list(myTrnDataset1, myTrnDatasetLog1)
    }else{
      listOfDatasetsToReturn <- list(myTrnDataset1)
    }
  }

# case 2.
  #
  if(caseOfFactorization == "case2"){
    myTrnDataset2 <- mapFactorizer(datasetToFactorize)

    if(setToFactorize == "train"){
      myTrnDatasetLog2 <- myTrnDataset2 %>% mutate(loss = log(loss))
      listOfDatasetsToReturn<- list(myTrnDataset2, myTrnDatasetLog2)
    }else{
      listOfDatasetsToReturn<- list(myTrnDataset2)
    }
  }

# case 3.
  #
  if(caseOfFactorization == "case3"){
    myTrnDataset3 <- columnSplitterAndFactorizer(datasetToFactorize)

    if(setToFactorize == "train"){
      myTrnDatasetLog3 <- myTrnDataset3 %>% mutate(loss = log(loss))
      listOfDatasetsToReturn <- list(myTrnDataset3, myTrnDatasetLog3)
    }else{
      listOfDatasetsToReturn <- list(myTrnDataset3)
    }

  }


  if(setToFactorize == "train"){
    names(listOfDatasetsToReturn) <- c("myDataset", "myDatasetLog")
  }else{
    names(listOfDatasetsToReturn) <- c("myDataset")
  }


  return(listOfDatasetsToReturn)





}


