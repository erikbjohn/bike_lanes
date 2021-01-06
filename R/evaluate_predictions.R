evaluate_predictions <- function(){
  test_predictions <- fread('predictions/testing_predictions.csv')
  train_predictions <- fread('predictions/training_predictions.csv')
  plot(train_predictions$actual_width, train_predictions$predicted_width)
  plot(test_predictions$actual_width, test_predictions$predicted_width)
  
  test_predictions <- test_predictions[, diff:=predicted_width-actual_width]
  
  ggplot2::ggplot(data=train_predictions, aes(x=actual_width, y=predicted_width)) +
    geom_point() +
    xlim(c(0,100)) +
    ylim(c(0,100)) + 
    geom_abline(slope=1, intercept=0) +
    ggtitle('Training Data')
  
  ggplot2::ggplot(data=test_predictions, aes(x=actual_width, y=predicted_width)) +
    geom_point() +
    xlim(c(0,100)) +
    ylim(c(0,100)) + 
    geom_abline(slope=1, intercept=0) +
    ggtitle('Testing Data')
  
  ggsave('test_data_predictions.png')
  
}