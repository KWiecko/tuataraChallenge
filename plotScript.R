# creating plots
library(ggplot2)
library(dplyr)
library(gridExtra)
library(cowplot)
q <- data.frame(q)
names(q) <- c("loss")
lossHist <- ggplot(q, aes(loss)) + 
            geom_histogram(aes(fill = ..count..)) + 
            scale_fill_gradient("Count", low = "green", high = "red")
p <- q %>% filter(loss <= 15000)
lossHistNoOutliers <- ggplot(p, aes(loss)) + 
  geom_histogram(aes(fill = ..count..)) + 
  scale_fill_gradient("Count", low = "green", high = "red")

plot_grid(lossHist, lossHistNoOutliers, align = "h", ncol = 2,  rel_heights = c(1/2, 1/2))



qLog <- log(q)
lossHistLog <- ggplot(qLog, aes(loss)) + 
  geom_histogram(aes(fill = ..count..)) + 
  scale_fill_gradient("Count", low = "green", high = "red")

qLog <- log(q) %>% filter(loss >= 4 & loss <= 12)
lossHistLogNoOutliers <- ggplot(qLog, aes(loss)) + 
  geom_histogram(aes(fill = ..count..)) + 
  scale_fill_gradient("Count", low = "green", high = "red")

plot_grid(lossHistLog, lossHistLogNoOutliers, align = "h", ncol = 2,  rel_heights = c(1/2, 1/2))


boxplotData <- data.frame(myInitialFactorizedData$myDataset$cat1,
                          myInitialFactorizedData$myDataset$cat4,
                          myInitialFactorizedData$myDataset$cat75,
                          myInitialFactorizedData$myDataset$cat110,
                          myInitialFactorizedData$myDataset$cont1,
                          myInitialFactorizedData$myDataset$cont5,
                          myInitialFactorizedData$myDataset$cont12)

names(boxplotData) <- c("cat1", "cat4", "cat75", "cat110", "cont1", "cont5", "cont12")

boxplotData1 <- boxplotData %>% select(cat1, cat4, cat75)
boxplotData2 <- boxplotData %>% select(cat110)
boxplotData3 <- boxplotData %>% select(cont1, cont5, cont12)

for(nameIdx in 1:length(names(boxplotData3))){
  
  varName <- rep(colnames(boxplotData3)[nameIdx], length(boxplotData3[,1] %>% unlist() %>% as.vector()))
  
  if(nameIdx == 1){
    
    boxplotDataPlotDF <- data.frame(boxplotData3[, nameIdx], varName)
    names(boxplotDataPlotDF) <- c("value", "variable")
    
  }else{
    
    transferDF <- data.frame(boxplotData3[, nameIdx], varName)
    names(transferDF) <- c("value", "variable")
    boxplotDataPlotDF <- rbind(boxplotDataPlotDF, transferDF)
    
  }
  
}

boxPlotsCat1 <- ggplot(boxplotDataPlotDF, aes(variable, value)) + 
               geom_boxplot(outlier.colour = "red", outlier.shape = 1)

boxPlotsCat2 <-  ggplot(boxplotDataPlotDF, aes(variable, value)) + 
                geom_boxplot(outlier.colour = "red", outlier.shape = 1)

boxPlotsCat3 <-  ggplot(boxplotDataPlotDF, aes(variable, value)) + 
                geom_boxplot(outlier.colour = "red", outlier.shape = 1)

plot_grid(boxPlotsCat1, boxPlotsCat2, boxPlotsCat3,  align = "v", nrow = 3,  rel_heights = c(1, 1, 1))


cont1<- boxplotData3$cont1 %>% cut(breaks = 50, labels = FALSE)
cont1 <- data.frame(cont1)
lossCont1 <- ggplot(cont1, aes(cont1)) + 
  geom_histogram(aes(fill = ..count..)) + 
  scale_fill_gradient("Count", low = "green", high = "red") 

cont5<- boxplotData3$cont5 %>% cut(breaks = 50, labels = FALSE)
cont5 <- data.frame(cont5)
lossCont5 <- ggplot(cont5, aes(cont5)) + 
  geom_histogram(aes(fill = ..count..)) + 
  scale_fill_gradient("Count", low = "green", high = "red")

cont12<- boxplotData3$cont12 %>% cut(breaks = 50, labels = FALSE)
cont12 <- data.frame(cont12)
lossCont12 <- ggplot(cont12, aes(cont12)) + 
  geom_histogram(aes(fill = ..count..)) + 
  scale_fill_gradient("Count", low = "green", high = "red")

plot_grid(lossCont1, lossCont5, lossCont12,  align = "v", nrow= 3,  rel_heights = c(1/2, 1/2, 1/2))

#RMSE XGB
MSECorrToLossCase1OL <- c(4924574, 4683748, 5339088, 6804672)
MSECorrToLossCase1LogOL <- c(5246103, 4984535, 5541112, 6735721 )
MSEWeakCorrCase1OL <- c(6061977, 5973994, 5975858, 5975858)
MSEWeakCorrCase1LogOL <- c(6484982, 6387087, 6386215, 6386218)


MSECorrToLossCase2OL <- c(4924574, 4683748, 5339088, 6804672)
MSECorrToLossCase2LogOL <- c(5246130, 4984535,  5541112, 6735721)
MSEWeakCorrCase2OL <- c(6061977, 5973994, 5975858, 5795858)
MSEWeakCorrCase2LogOL <- c(6484982, 6387087, 6386215, 6386218)

MSECorrToLossCase1TestNOL <- c(3016203, 2897326, 3472200, 5000635)
MSECorrToLossCase1LogTestNOL <- c(3017993, 2848267, 3412969, 4674924)
MSEWeakCorrCase1TestNOL <- c(3555154, 3517002, 3517239, 3517242)
MSEWeakCorrCase1LogTestNOL <- c(3563887, 3499254, 3498159, 3498111)

MSECorrToLossCase1NOL <- c(2775022, 2556672, 2686353, 3217079)
MSECorrToLossCase1LogNOL <- c(2976067, 2734682, 2900014, 3498957)
MSEWeakCorrCase1NOL <- c(3288376, 3255693, 3254485, 3254488)
MSEWeakCorrCase1LogNOL <- c(3534913, 3504613, 3503015, 3503017)

RMSEXGB <- data.frame(MSECorrToLossCase1OL, MSECorrToLossCase1LogOL, MSEWeakCorrCase1OL, MSEWeakCorrCase1LogOL,
                     MSECorrToLossCase2OL, MSECorrToLossCase2LogOL, MSEWeakCorrCase2OL, MSEWeakCorrCase2LogOL,
                     MSECorrToLossCase1TestNOL, MSECorrToLossCase1LogTestNOL, MSEWeakCorrCase1TestNOL, MSEWeakCorrCase1LogTestNOL,
                     MSECorrToLossCase1NOL, MSECorrToLossCase1LogNOL, MSEWeakCorrCase1NOL, MSEWeakCorrCase1LogNOL) %>% sqrt() %>% round(., 0)

names(RMSEXGB) <- c("case1 with outliers, CTL", "case1 with outliers, CTL,ln(loss)", "case1 with outliers, WC", "case1 with outliers, WC, ln(loss)",
                    "case2 with outliers, CTL", "case2 with outliers, CTL, ln(loss)", "case2 with outliers, WC", "case2 with outliers, WC, ln(loss)",
                    "case1 test w/o outliers, CTL", "case1 test w/o outliers, CTL, ln(loss)", "case1 test w/o outliers, WC", "case1 test w/o outliers, WC, ln(loss)", 
                    "case1 w/o outliers, CTL", "case1 w/o outliers, CTL, ln(loss)", "case1 w/o outliers, WC", "case1 w/o outliers, WC, ln(loss)")

#names(RMSEXGB) <- c(1:16) %>% as.character()

for(nameIdx in 1:length(names(RMSEXGB))){
  
  varName <- rep(colnames(RMSEXGB)[nameIdx], length(RMSEXGB[,1] %>% unlist() %>% as.vector()))
  tree_depth <- c(2, 5, 10, 15)
  
  if(nameIdx == 1){
    
    RMSEXGBplotDataPlotDF <- data.frame(RMSEXGB[, nameIdx], tree_depth ,varName)
    names(RMSEXGBplotDataPlotDF) <- c("RMSE", "Tree depth","Dataset")
    
  }else{
    
    transferDF <- data.frame(RMSEXGB[, nameIdx], tree_depth,varName)
    names(transferDF) <- c("RMSE", "Tree depth","Dataset")
    RMSEXGBplotDataPlotDF <- rbind(RMSEXGBplotDataPlotDF, transferDF)
    
  }
  
}

RMSE_plot <- ggplot(RMSEXGBplotDataPlotDF, aes(y = RMSE, x = `Tree depth`, color = Dataset)) +
  geom_line(aes(linetype = Dataset), size = 1)

AICcase1CorrToLossGLMOL <- c(916586)
AICcase1CorrToLossGLMLogOL <- c(93278)
AICcase1WeakCorrGLMOL <- c(928686)
AICcase1WeakCorrGLMLogOL <- c(105855)
AICcase2CorrToLossGLMOL <- c(916577)
AICcase2CorrToLossGLMLogOL <- c(93237)
AICcase2WeakCorrGLMOL <- c(928686)
AICcase2WeakCorrGLMLogOL <- c(105855)
AICcase1CorrToLossGLMTestNOL <- c(916586)
AICcase1CorrToLossGLMLogTestNOL <- c(93278.1)
AICcase1WeakCorrGLMTestNOL <- c(928686)
AICcase1WeakCorrGLMLogTestNOL <- c(105855)
AICcase1CorrToLossGLMNOL <- c(881667.1)
AICcase1CorrToLossGLMLogNOL <- c(85521)
AICcase1WeakCorrGLMNOL <- c(894429.6)
AICcase1WeakCorrGLMLogNOL <- c(97325.32)

AICDF <- data.frame(c(
AICcase1CorrToLossGLMOL,
AICcase1CorrToLossGLMLogOL,
AICcase1WeakCorrGLMOL,
AICcase1WeakCorrGLMLogOL,
AICcase2CorrToLossGLMOL,
AICcase2CorrToLossGLMLogOL,
AICcase2WeakCorrGLMOL,
AICcase2WeakCorrGLMLogOL,
AICcase1CorrToLossGLMTestNOL,
AICcase1CorrToLossGLMLogTestNOL,
AICcase1WeakCorrGLMTestNOL,
AICcase1WeakCorrGLMLogTestNOL,
AICcase1CorrToLossGLMNOL,
AICcase1CorrToLossGLMLogNOL,
AICcase1WeakCorrGLMNOL,
AICcase1WeakCorrGLMLogNOL
)) %>% round(., 0)

lossType <- c("loss", "ln(loss)",
              "loss", "ln(loss)",
              "loss", "ln(loss)",
              "loss", "ln(loss)",
              "loss", "ln(loss)",
              "loss", "ln(loss)",
              "loss", "ln(loss)",
              "loss", "ln(loss)")

Dataset <- c("case1 with outliers, CTL", "case1 with outliers, CTL", "case1 with outliers, WC", "case1 with outliers, WC",
              "case2 with outliers, CTL", "case2 with outliers, CTL", "case2 with outliers, WC", "case2 with outliers, WC",
              "case1 test w/o outliers, CTL", "case1 test w/o outliers, CTL", "case1 test w/o outliers, WC", "case1 test w/o outliers, WC", 
              "case1 w/o outliers, CTL", "case1 w/o outliers, CTL", "case1 w/o outliers, WC", "case1 w/o outliers, WC")

AICDF <- cbind(AICDF, lossType, Dataset)
names(AICDF) <- c("AIC", "loss type", "Dataset")
AICPlot <- ggplot(AICDF, aes(x = Dataset, y = AIC)) + 
  geom_bar(aes(fill = `loss type`), stat= "identity", position = "dodge") + 
  coord_flip() + 
  geom_text(aes(label = AIC)) + 
  guides(fill = FALSE)


MSEcase1CorrToLossGLMOL <- c(4662565)
MSEcase1CorrToLossGLMLogOL <- c(5313457)
MSEcase1WeakCorrGLMOL <- c(6143873)
MSEcase1WeakCorrGLMLogOL <- c(6552392)
MSEcase2CorrToLossGLMOL <- c(4661613)
MSEcase2CorrToLossGLMLogOL <- c(5308956)
MSEcase2WeakCorrGLMOL <- c(6143873)
MSEcase2WeakCorrGLMLogOL <- c(6552392)
MSEcase1CorrToLossGLMTestNOL <- c(2814718)
MSEcase1CorrToLossGLMLogTestNOL <- c(3327083)
MSEcase1WeakCorrGLMTestNOL <- c(3565130)
MSEcase1WeakCorrGLMLogTestNOL <- c(3578600)
MSEcase1CorrToLossGLMNOL <- c(2560487)
MSEcase1CorrToLossGLMLogNOL <- c(3044170)
MSEcase1WeakCorrGLMNOL <- c(3325533)
MSEcase1WeakCorrGLMLogNOL <- c(3596357)

RMSEDF <- data.frame(c(
  MSEcase1CorrToLossGLMOL,
  MSEcase1CorrToLossGLMLogOL,
  MSEcase1WeakCorrGLMOL,
  MSEcase1WeakCorrGLMLogOL,
  MSEcase2CorrToLossGLMOL,
  MSEcase2CorrToLossGLMLogOL,
  MSEcase2WeakCorrGLMOL,
  MSEcase2WeakCorrGLMLogOL,
  MSEcase1CorrToLossGLMTestNOL,
  MSEcase1CorrToLossGLMLogTestNOL,
  MSEcase1WeakCorrGLMTestNOL,
  MSEcase1WeakCorrGLMLogTestNOL,
  MSEcase1CorrToLossGLMNOL,
  MSEcase1CorrToLossGLMLogNOL,
  MSEcase1WeakCorrGLMNOL,
  MSEcase1WeakCorrGLMLogNOL) %>% sqrt() %>% round(.,0)
  
  )

RMSEDF <- cbind(RMSEDF, lossType, Dataset)
names(RMSEDF) <- c("RMSE", "loss type", "Dataset")

RMSEPlot <- ggplot(RMSEDF, aes(x = Dataset, y = RMSE)) + 
  geom_bar(aes(fill = `loss type`), stat= "identity", position = "dodge") + 
  theme(axis.title.y = element_blank(), axis.text.y = element_blank()) + 
  coord_flip() + 
  geom_text(aes(label = RMSE, vjust = ifelse(`loss type` == "loss", -1, 2)))

Rcase1CorrToLossGLMOL <- c(0.435)
Rcase1CorrToLossGLMLogOL <- c(0.628)
Rcase1WeakCorrGLMOL <- c(0.268)
Rcase1WeakCorrGLMLogOL <- c(0.423)
Rcase2CorrToLossGLMOL <- c(0.435)
Rcase2CorrToLossGLMLogOL <- c(0.628)
Rcase2WeakCorrGLMOL <- c(0.268)
Rcase2WeakCorrGLMLogOL <- c(0.423)
Rcase1CorrToLossGLMTestNOL <- c(0.6870798)
Rcase1CorrToLossGLMLogTestNOL <- c(0.7722181)
Rcase1WeakCorrGLMTestNOL <- c(0.4766383)
Rcase1WeakCorrGLMLogTestNOL <- c(0.5746802)
Rcase1CorrToLossGLMNOL <- c(0.4459935)
Rcase1CorrToLossGLMLogNOL <- c(0.6923635)
Rcase1WeakCorrGLMNOL <- c(0.2665413)
Rcase1WeakCorrGLMLogNOL <- c(0.5093917)

RDF <- data.frame(c(
  
  Rcase1CorrToLossGLMOL,
  Rcase1CorrToLossGLMLogOL ,
  Rcase1WeakCorrGLMOL,
  Rcase1WeakCorrGLMLogOL,
  Rcase2CorrToLossGLMOL ,
  Rcase2CorrToLossGLMLogOL ,
  Rcase2WeakCorrGLMOL ,
  Rcase2WeakCorrGLMLogOL ,
  Rcase1CorrToLossGLMTestNOL ,
  Rcase1CorrToLossGLMLogTestNOL ,
  Rcase1WeakCorrGLMTestNOL ,
  Rcase1WeakCorrGLMLogTestNOL ,
  Rcase1CorrToLossGLMNOL ,
  Rcase1CorrToLossGLMLogNOL ,
  Rcase1WeakCorrGLMNOL ,
  Rcase1WeakCorrGLMLogNOL
  
) %>% round(.,2)
)

RDF <- cbind(RDF, lossType, Dataset)
names(RDF) <- c("R2_adj", "loss type", "Dataset")

RDF <- ggplot(RDF, aes(x = Dataset, y = R2_adj)) + 
  geom_bar(aes(fill = `loss type`), stat= "identity", position = "dodge") + 
  theme(axis.title.y = element_blank(), axis.text.y = element_blank()) + 
  coord_flip() + 
  geom_text(aes(label = R2_adj, vjust = ifelse(`loss type` == "loss", -1, 2))) +
  guides(fill = FALSE) 

plot_grid(AICPlot, RDF, RMSEPlot,  align = "h", ncol= 3, rel_widths = c(1, 1/2, 2/3))
