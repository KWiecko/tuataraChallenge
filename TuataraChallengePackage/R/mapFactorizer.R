#'
#' Function to factorize dataset loaded from HDFS
#'
#' @param  List returned by function 'readDataFromHDFS()'
#' @return List: [[1]] Sparklyr connection object, [[2]] Factorized training dataset [[3]] Factorized testing dataset
#' @export
#'


mapFactorizer <- function(datasetToFactorize){

  #loading rquired packages
  library(TuataraChallengePackage)
  library(sparklyr)
  library(dplyr)


  # getting columns to factorize
  columnsToFactorize <- datasetToFactorize %>%
                        select(contains("cat")) %>%
                        colnames()


  #finding all levels in all columns
  uniqueDFLevels <- lapply(select(datasetToFactorize, contains("cat")), unique) %>%
       unlist() %>%
       as.vector() %>%
       unique()
  #mapping them to integers
  uniqueDFLevelsMap <- as.integer(factor(uniqueDFLevels, labels = c(1:length(uniqueDFLevels))))
  uniqueDFLevelsMapDF <- data.frame(uniqueDFLevels, uniqueDFLevelsMap)


  for(colIdx in 2:(length(columnsToFactorize) + 1) ){
    print(paste0("Dataset mapped and factorized in ", round(100 * colIdx/(length(columnsToFactorize) + 1), 2) , "%"))
    charsToBeMappedIdx <- grep(pattern = paste0("^",levels(factor(datasetToFactorize[ , colIdx] %>% unlist() %>% as.vector())), "$", collapse = "|"),
                          uniqueDFLevels)

    replacementMap <- uniqueDFLevelsMapDF[charsToBeMappedIdx,]


    for(mapIdx in 1:length(replacementMap[,1])){
      datasetToFactorize[ , colIdx]<- gsub(pattern = paste0("^", replacementMap[mapIdx, 1], "$"),
                                            replacement = replacementMap[mapIdx, 2],
                                           datasetToFactorize[ , colIdx] %>% unlist() %>% as.vector)
    }

    datasetToFactorize[ , colIdx]  <- datasetToFactorize[ , colIdx] %>%
                                     unlist() %>%
                                     as.vector() %>%
                                     as.integer()

  }

  return(datasetToFactorize);

}


