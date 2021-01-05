evaluate_predictions <- function(){
  test_predictions <- fread('predictions/testing_predictions.csv')
  train_predictions <- fread('predictions/training_predictions.csv')
  plot(train_predictions$actual_width, train_predictions$predicted_width)
  plot(test_predictions$actual_width, test_predictions$predicted_width)
}