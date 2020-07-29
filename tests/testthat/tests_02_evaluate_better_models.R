library(data.table)
library(testthat)

setwd("/workdir/")
source("src/02_evaluate_better_models.R")
source("tests/data/02_evaluate_better_models_tests.R")

json_correct_data_path <- ("tests/data/best_logistic_model_parameters_laal_ig_tests.json")
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)
json_data_path <- ("data/processed/best_logistic_model_parameters_laal_ig.json")
json_data <- rjson::fromJSON(file = json_data_path)

csv_data_path <- file.path("data/processed/best_models_table.csv")
csv_data <- data.table(read.csv(csv_data_path))
csv_correct_data_path <- file.path("tests/data/best_models_table_tests.csv")
csv_correct_data <- data.table(read.csv(csv_correct_data_path))

test_that("Los resultados generados del código son correctos:",
    {
        expect_equal(json_data, json_correct_data)
        expect_equal(csv_data, csv_correct_data)
    }
)

test_that("El valor umbral es correcto:",
    {
        expect_equal(threshold, correct_threshold)
    }
)

test_that("Los resultados de predicción son correctos",
    {
        expect_equal(y_test, correct_y_test)
    }
)