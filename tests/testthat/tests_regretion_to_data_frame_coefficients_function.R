setwd("/workdir/")
source("src/01_create_parameter_logistic_model_LAAL.R")
source("src/regretion_to_data_frame_coefficients_function.R")

step_coefficients <- regretion_to_data_frame(step_regression)

test_that("La función regresa regretion_to_data_frame un data_frame",
    {
        expect_equal(class(step_coefficients), "data.frame")
    }
)