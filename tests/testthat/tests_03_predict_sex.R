library(testthat)

setwd("/workdir/")
source("src/03_predict_sex.R")

json_correct_data_path <- "tests/data/best_logistic_model_parameters_laal_ig_tests.json"
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)
json_data_path <- "data/processed/logistic_model_parameters.json"
json_data <- rjson::fromJSON(file = json_data_path)

correct_males <- c(
  T, F, T, F, T, T, F, T, F, T, T, T, 
  F, F, F, T, T, F, T, T, F, T, F, T, 
  F, F, F, F, F, F, F, T, F, F, T, T, 
  F, F, F, F, F, F, F, F, F, F, F, F, 
  F, F, F, F, F, F, F, F, F, F, F, F, 
  F, F, F, F, F, F, F, F, F, F, F, F, 
  F, F, F, T, F, T, T, T, F, T, F, F, 
  F, T, F, T, T, T, T, T, T, T, T, T, 
  F, T, T, T, T, T, T, T, T, F, F, F, 
  F, F, F, F, F, T, F, F, F, F, F, F, 
  F, F, F, T, T, T, T, T, F, T, T, T, 
  T, F, T
)

test_that("Los resultados generados del código son correctos:", {
  correct_length <- 43
  obtained_length <- length(readLines(json_data_path))
  expect_equal(correct_length, obtained_length)
  expect_equal(json_data, json_correct_data)
})

test_that("El valor umbral es correcto:", {
  correct_threshold <- 0.295
  expect_equal(threshold, correct_threshold)
})

test_that("La probabilidad de error con 10 repeticiones es correcta:", {
  correct_prob <- 0.824
  tdp_path <- "data/raw/"
  csv_file <- file.path(tdp_path, "laysan_albatross_morphometry_guadalupe.csv")
  csv_data <- data.table::data.table(read.csv(csv_file))
  n_rows_data <- nrow(csv_data)
  data <- csv_data[n_rows_data, ]
  prob <- dimorphism_model_albatross$predict(data)
  expect_equivalent(prob, correct_prob, tolerance = 1e-3)
})

test_that("Los resultados finales son correctos:", {
  expect_equivalent(males, correct_males)
})
