library(data.table)
library(dimorfismo)
library(testthat)

get_private <- function(object) {
  object[[".__enclos_env__"]]$private
}

setwd("/workdir/")
dimorphism_class_tester <- dimorphism_model$new()
dimorphism_class_expected <- dimorphism_model$new()

json_correct_data_path <- "tests/data/best_logistic_model_parameters_laal_ig_tests.json"
json_data_path <- "data/processed/best_logistic_model_parameters_laal_ig.json"

test_that("El método load_parameters funciona: ", {
  correct_model_parameters <- dimorphism_class_expected$load_parameters(json_correct_data_path)
  model_parameters <- dimorphism_class_tester$load_parameters(json_data_path)
  expect_equal(model_parameters, correct_model_parameters)
})

json_file_path <- "tests/data/logistic_model_parameters_tests.json"
dimorphism_class_tester$load_parameters(json_file_path)
csv_file <- "data/raw/laysan_albatross_morphometry_guadalupe.csv"
csv_data <- data.table(read.csv(csv_file))
data_training <- csv_data[1:5, ]

test_that("El método predict funciona: ", {
  correct_prediction <- data.frame(
    "probability" = c(0.9916232780, 0.0005606211, 0.9904448866, 0.2978475227, 0.9617133474)
  )
  prediction <- dimorphism_class_tester$predict(data_training)
  expect_equivalent(colnames(prediction), colnames(correct_prediction))
  expect_equivalent(prediction, correct_prediction)
})

test_that("La función privada get_estimate_value funciona: ", {
  correct_estimate_peak <- 6.648
  correct_intercept <- -12.87
  estimate_intercept <- get_private(dimorphism_class_tester)$get_estimate_value("(Intercept)")
  estimate_peak <- get_private(dimorphism_class_tester)$get_estimate_value("beak_length")
  expect_equal(estimate_intercept, correct_intercept)
  expect_equal(estimate_peak, correct_estimate_peak)
})
