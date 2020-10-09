library(testthat)

setwd("/workdir/")
source("tests/data/03_predict_sex_data_tests.R")
source("src/03_predict_sex.R")

json_correct_data_path <- ("tests/data/best_logistic_model_parameters_laal_ig_tests.json")
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)
json_data_path <- ("data/processed/logistic_model_parameters.json")
json_data <- rjson::fromJSON(file = json_data_path)

test_that("Los resultados generados del código son correctos:", {
  obtained_length <- length(readLines(json_data_path))
  correct_length <- 43
  expect_equal(json_data, json_correct_data)
  expect_equal(correct_length, correct_length)
})

test_that("El valor umbral es correcto:", {
  expect_equal(threshold, correct_threshold)
})

test_that("La probabilidad de error es correcta:", {
  expect_equivalent(prob, correct_prob)
})

test_that("Los resultados finales son correctos:", {
  expect_equivalent(males, correct_males)
})
