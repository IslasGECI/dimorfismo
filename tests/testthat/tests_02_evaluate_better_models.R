library(data.table)
library(testthat)

setwd("/workdir/")
source("src/02_evaluate_better_models.R")

csv_correct_data_path <- file.path("tests/data/best_models_table_tests.csv")
csv_data_path <- file.path("data/processed/best_models_table.csv")
json_correct_data_path <- "tests/data/best_logistic_model_parameters_laal_ig_tests.json"
json_data_dir <- "data/processed/logistic_model_parameters.json"
json_data_path <- "data/processed/best_logistic_model_parameters_laal_ig.json"

correct_y_test <- c(
  1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0,
  0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
)

test_that("Los resultados generados del código son correctos y siguen la guía de estilo:", {
  csv_correct_data <- data.table(read.csv(csv_correct_data_path))
  csv_data <- data.table(read.csv(csv_data_path))
  expect_equal(csv_data, csv_correct_data)
  json_correct_data <- rjson::fromJSON(file = json_correct_data_path)
  json_data <- rjson::fromJSON(file = json_data_path)
  expect_equal(json_data, json_correct_data)
  expected_length <- 43
  obtained_length <- length(readLines(json_data_path))
  expect_equal(obtained_length, expected_length)
  outcome_length_json <- length(readLines(json_data_dir))
  expect_equal(outcome_length_json, expected_length)
})

test_that("El valor umbral es correcto:", {
  correct_threshold <- 0.295
  expect_equal(threshold, correct_threshold)
})

test_that("Los resultados de predicción son correctos", {
  expect_equal(y_test, correct_y_test)
})

test_that("Los resultados de error en curva ROC son correctos", {
  data <- read_csv("data/raw/laysan_albatross_morphometry_guadalupe.csv")
  dimorphism_model_albatross <- dimorphism_model$new()
  dimorphism_model_albatross$load_parameters(json_data_dir)
  prob <- dimorphism_model_albatross$predict(data)
  y_test <- correct_y_test
  roc_data <- data.frame(y_test, prob)
  roc_error_outcome <- calculador_roc$calculate_error(roc_data, threshold)
  correct_error_roc <- 13.322
  expect_equivalent(roc_error_outcome, correct_error_roc, tolerance = 1e-3)
})
