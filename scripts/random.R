##Function for random CV

random_cv <- function(pa_data, cropped_env, cropped_env_test, 
                      pa_data_test,
                      cropped_env_fut){
  mydata <- raster::extract(cropped_env, pa_data, df = TRUE)
  mydata$occurrenceStatus <- as.factor(pa_data$occurrenceStatus)
  mydata <- mydata %>% 
    mutate_if(is.numeric, ~replace_na(.,mean(., na.rm = TRUE)))
  mydata <- mydata[-1]
  inTrain <- createDataPartition(
    y = mydata$occurrenceStatus,
    p = .75,
    list = FALSE
  )
  levels(mydata$occurrenceStatus) <- c("absence","present" )
  training <- mydata[ inTrain,]
  testing  <- mydata[-inTrain,]
  
  
  predictorsNames <- names(mydata)[names(mydata) != 'occurrenceStatus']
  objControl <- trainControl(method='cv', number=5, returnResamp='none', summaryFunction = twoClassSummary, classProbs = TRUE)
  objModel <- train(training[,predictorsNames], training[,'occurrenceStatus'], 
                    method='rf', 
                    trControl=objControl,  
                    metric = "ROC",
                    preProc = c("center", "scale"))
  
  predictions <- predict(object=objModel, testing[,predictorsNames], type='prob')
  
  testing[,'occurrenceStatus'] <- ifelse(testing[,'occurrenceStatus']=="present",1,0)
  testing$pred <- predictions[[2]]
  testing <- as.data.frame(testing)
  
  
  
  ##PAST
  mydata_test <- raster::extract(cropped_env_test, pa_data_test, df = TRUE)
  mydata_test$occurrenceStatus <- as.factor(pa_data_test$occurrenceStatus)
  mydata_test <- mydata_test %>% 
    mutate_if(is.numeric, ~replace_na(.,mean(., na.rm = TRUE)))
  mydata_test <- mydata_test[-1]
  inTrain <- createDataPartition(
    y = mydata_test$occurrenceStatus,
    p = .75,
    list = FALSE
  )
  levels(mydata_test$occurrenceStatus) <- c("absence","present" )
  training_test <- mydata_test[ inTrain,]
  testing_test  <- mydata_test[-inTrain,]
  
  predictorsNames <- names(mydata_test)[names(mydata_test) != 'occurrenceStatus']
  predictions_test <- predict(object=objModel, testing_test[,predictorsNames], type='prob')
  testing_test[,'occurrenceStatus'] <- ifelse(testing_test[,'occurrenceStatus']=="present",1,0)
  testing_test$pred <- predictions_test[[2]]
  testing_test <- as.data.frame(testing_test)
  
  bio_curr_df <- data.frame(rasterToPoints(cropped_env))
  bio_curr_df$pred <- predict(objModel, bio_curr_df,type = "prob")[,2]
  bio_curr_df <- bio_curr_df[,c('x', 'y', 'pred')]
  
  bio_test_df <- data.frame(rasterToPoints(cropped_env_test))
  bio_test_df$pred <- predict(objModel, bio_test_df,type = "prob")[,2]
  bio_test_df <- bio_test_df[,c('x', 'y', 'pred')]
  
  bio_fut_df <- data.frame(rasterToPoints(cropped_env_fut))
  bio_fut_df$pred <- predict(objModel, bio_fut_df,type = "prob")[,2]
  bio_fut_df <- bio_fut_df[,c('x', 'y', 'pred')]
  
  out = list(testing, bio_curr_df, testing_test, bio_test_df, bio_fut_df)
  return(out)
  
}

random_res <- random_cv(pa_data, cropped_env, cropped_env_test, pa_data_test, cropped_env_fut)

random_pred <- as.data.frame(random_res[1])
random_pred_past <- as.data.frame(random_res[3])

random_curr_map <- as.data.frame(random_res[2])
random_past_map <- as.data.frame(random_res[4])
random_fut_map <- as.data.frame(random_res[5])

lst_random_maps <- list(random_curr_map, random_past_map, random_fut_map)
change_names <- function(lst_random_maps){
  for (i in seq_along(lst_random_maps )) {
    names(lst_random_maps [[i]]) <- c("longitude", "latitude", "pred")
  }
  return(lst_random_maps)
}

random_curr_map <- as.data.frame(change_names(lst_random_maps)[1])
random_past_map <- as.data.frame(change_names(lst_random_maps)[2])
random_fut_map <- as.data.frame(change_names(lst_random_maps)[3])


##Save results of current and past predictions
write.csv(random_pred,'C:/Users/User/Desktop/project_ml_team29/results/random_pred.csv')
write.csv(random_pred_past,'C:/Users/User/Desktop/project_ml_team29/results/random_pred_past.csv')


my_colors_3 <- c( "#008fbf", "#47b0df",
                  "#dae695", '#e6ae95', 
                  "#df7b7b", "#a00000" )

curr_plot <- ggplot() +
  geom_raster(data = random_curr_map , aes(x = longitude, y = latitude, fill = pred)) +
  #scale_fill_distiller(palette = "Spectral", direction = -1, na.value = "white") +
  scale_fill_gradientn (colours = my_colors_3, na.value = "white", limits = c(0,1))+
  coord_quickmap()+
  theme_classic(base_size = 12, base_family = "Georgia")+theme(legend.position = "bottom") +
  ggtitle('random CV') +
  theme(text=element_text(size=12)) +
  theme(plot.title = element_text(hjust = 0.5))

##Save map of current prediction
png("C:/Users/User/Desktop/project_ml_team29/figures/random_cv_map_curr.png")
print(curr_plot)
dev.off()


past_plot <- ggplot() +
  geom_raster(data = random_past_map , aes(x = longitude, y = latitude, fill = pred)) +
  #scale_fill_distiller(palette = "Spectral", direction = -1, na.value = "white") +
  scale_fill_gradientn (colours = my_colors_3, na.value = "white", limits = c(0,1))+
  coord_quickmap()+
  theme_classic(base_size = 12, base_family = "Georgia")+theme(legend.position = "bottom") +
  ggtitle('random CV 1994-2009') +
  theme(text=element_text(size=12)) +
  theme(plot.title = element_text(hjust = 0.5))

##Save map of past prediction
png("C:/Users/User/Desktop/project_ml_team29/figures/random_cv_map_past.png")
print(past_plot)
dev.off()


fut_plot <- ggplot() +
  geom_raster(data = random_fut_map , aes(x = longitude, y = latitude, fill = pred)) +
  #scale_fill_distiller(palette = "Spectral", direction = -1, na.value = "white") +
  scale_fill_gradientn (colours = my_colors_3, na.value = "white", limits = c(0,1))+
  coord_quickmap()+
  theme_classic(base_size = 12, base_family = "Georgia")+theme(legend.position = "bottom") +
  ggtitle('random CV CanESM_126 2040-2060') +
  theme(text=element_text(size=12))+
  theme(plot.title = element_text(hjust = 0.5))


##Save map of future prediction
png("C:/Users/User/Desktop/project_ml_team29/figures/random_cv_map_future.png")
print(fut_plot)
dev.off()



## To check ROC AUC SCORE you can use 
random_scores <- evalmod(scores = random_pred$pred, labels = random_pred$occurrenceStatus)
autoplot(random_scores)

random_scores_past <- evalmod(scores = random_pred_past$pred, labels = random_pred_past$occurrenceStatus)
autoplot(random_scores_past)




