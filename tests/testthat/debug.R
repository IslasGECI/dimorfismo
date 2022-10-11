library(dimorfismo)
library(tidyverse)
library(data.table)

source("/workdir/R/regretion_to_data_frame_coefficients_function.R")

json_correct_data_path <- "tests/data/logistic_model_parameters_tests.json"
json_correct_data <- rjson::fromJSON(file = json_correct_data_path)
data_path <- "tests/data/laysan_albatross_morphometry_guadalupe.csv"
output_json_path <- "tests/data/output_best_json_for_logistic_model.json"
get_best_json_for_logistic_model(data_path, output_json_path)
testthat::expect_equal(output_json_path, json_correct_data)