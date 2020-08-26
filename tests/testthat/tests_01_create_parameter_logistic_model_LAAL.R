library(data.table)
library(testthat)

setwd("/workdir/")
source("src/01_create_parameter_logistic_model_LAAL.R")
source("tests/data/01_create_parameter_logistic_model_LAAL_tests.R")

test_that("El valor mínimo de error es correcto:",
    {
        expect_equivalent(minimum_error, correct_minimum_error)
    }
)

test_that("Los valores normalizados son correctos:",
    {
        expect_equivalent(min_normalized_data, correct_min_normalized_data)
        expect_equivalent(max_normalized_data, correct_max_normalized_data)
    }
)
