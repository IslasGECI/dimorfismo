library(data.table)
library(dimorfismo)
library(testthat)

get_private <- function(object) {
  object[['.__enclos_env__']]$private
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
