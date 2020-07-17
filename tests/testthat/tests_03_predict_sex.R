library(testthat)

setwd("/workdir/")
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
