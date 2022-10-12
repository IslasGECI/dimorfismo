library(data.table)
library(testthat)
library(tidyverse)

setwd("/workdir/")

test_that("Los resultados generados del código son correctos:", {
  data_path <- "tests/data/laysan_albatross_morphometry_guadalupe.csv"
  output_json_path <- "tests/data/output_best_json_for_logistic_model.json"
  get_best_json_for_logistic_model(data_path, output_json)
  expect_equal(output_json_path, json_correct_data)
  correct_lenght <- 58
  obtained_length <- length(readLines(json_data_path))
  expect_equal(obtained_length, correct_lenght, tolerance = 1)
})

source("src/01_create_parameter_logistic_model_LAAL.R")

correct_y_test <- c(
  1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
  1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
  1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0,
  0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1,
  1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0,
  0, 0, 0, 0, 0, 1, 1
)

json_data_path <- "data/processed/logistic_model_parameters.json"
json_data <- rjson::fromJSON(file = json_data_path)
json_correct_data_path <- "tests/data/logistic_model_parameters_tests.json"
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)

test_that("El valor mínimo de error es correcto:", {
  correct_minimum_error <- 7.40740740740740655212448473
  expect_equivalent(minimum_error, correct_minimum_error)
})

test_that("Los valores normalizados son correctos:", {
  correct_max_normalized_data <- c(119.48, 35.50, 193.22, 99.69)
  expect_equivalent(max_normalized_data, correct_max_normalized_data)
  correct_min_normalized_data <- c(100.81, 28.85, 166.60, 83.18)
  expect_equivalent(min_normalized_data, correct_min_normalized_data)
})

test_that("El valor de prueba es correcto:", {
  expect_equivalent(final_y_test, correct_y_test)
})
