library(data.table)
library(testthat)

setwd("/workdir/")
source("src/01_create_parameter_logistic_model_LAAL.R")
source("tests/data/01_create_parameter_logistic_model_LAAL_tests.R")

json_data_path <- ("data/processed/logistic_model_parameters.json")
json_data <- rjson::fromJSON(file = json_data_path)
json_correct_data_path <- ("tests/data/logistic_model_parameters_tests.json")
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)

test_that("El valor mínimo de error es correcto:", {
  expect_equivalent(minimum_error, correct_minimum_error)
})

test_that("Los valores normalizados son correctos:", {
  expect_equivalent(min_normalized_data, correct_min_normalized_data)
  expect_equivalent(max_normalized_data, correct_max_normalized_data)
})

test_that("El valor de prueba es correcto:", {
  expect_equivalent(final_y_test, correct_y_test)
})

test_that("Los resultados generados del código son correctos:", {
  obtained_length <- length(readLines(json_data_path))
  correct_lenght <- 58
  expect_equal(json_data, json_correct_data)
  expect_equal(obtained_length, correct_lenght)
})
