library(testthat)

setwd("/workdir/")
source("tests/data/03_predict_sex_data_tests.R")
source("src/03_predict_sex.R")

json_correct_data_path <- ("tests/data/logistic_model_parameters_tests.json")
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)
json_data_path <- ("data/processed/logistic_model_parameters.json")
json_data <- rjson::fromJSON(file = json_data_path)

test_that("Los resultados generados del código son correctos:",
    {
        expect_equal(json_data, json_correct_data)
    }
)

test_that("El valor umbral es correcto:",
    {
        expect_equal(threshold, correct_threshold)
    }
)
