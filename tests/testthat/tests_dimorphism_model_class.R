library(data.table)
library(dimorfismo)
library(testthat)

get_private <- function(object) {
  object[[".__enclos_env__"]]$private
}

setwd("/workdir/")
json_correct_data_path <- "tests/data/best_logistic_model_parameters_laal_ig_tests.json"
json_data_path <- "data/processed/best_logistic_model_parameters_laal_ig.json"

dimorphism_class_tester <- dimorphism_model$new()

test_that("El método load_parameters funciona: ", {
  dimorphism_class_tester$load_parameters(json_data_path)
  model_parameters <- get_private(dimorphism_class_tester)$model_parameters
  dimorphism_class_tester$load_parameters(json_correct_data_path)
  correct_model_parameters <- get_private(dimorphism_class_tester)$model_parameters
  expect_equal(model_parameters, correct_model_parameters)
})

dimorphism_class_tester <- dimorphism_model$new()
dimorphism_class_tester$load_parameters("tests/data/logistic_model_parameters_tests.json")

csv_file <- file.path("data/raw/laysan_albatross_morphometry_guadalupe.csv")
data <- data.table::data.table(read.csv(csv_file))
data_training <- data[1:5, ]
prediction <- dimorphism_class_tester$predict(data_training)
expected_prediction <- data.frame("probability" = c(0.9916232780, 0.0005606211, 0.9904448866, 0.2978475227, 0.9617133474))

test_that("El método predict funciona: ", {
  expect_equivalent(prediction, expected_prediction)
})
