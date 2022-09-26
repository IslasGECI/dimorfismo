library(data.table)
library(dimorfismo)
library(tidyverse)

set.seed(28)
setwd("/workdir/")
data_path <- "data/raw/"
get_best_json_for_logistic_model(data_path, output_json_path)
close(progress_bar)

no_intercept_variables <- c(
  "skull_length", "beak_height", "beak_length",
  "tarsus", "skull_width"
)

final_variables <- c(
  "(Intercept)", no_intercept_variables
)

model_table$model_coefficients <- model_table$model_coefficients[, final_variables]

model_table$standard_error <- model_table$standard_error[, final_variables]
colnames(model_table$standard_error) <- c(
  "error_std_intercept", "error_std_skull_length", "error_std_alto_pico",
  "error_std_beak_length", "error_std_tarsus", "error_std_skull_width"
)

model_table$z_value <- model_table$z_value[, final_variables]
colnames(model_table$z_value) <- c(
  "valor_z_intercept", "valor_z_skull_length", "valor_z_beak_height",
  "valor_z_beak_length", "valor_z_tarsus", "valor_z_skull_width"
)

model_table$pr_value <- model_table$pr_value[, final_variables]
colnames(model_table$pr_value) <- c(
  "pr_intercept", "pr_skull_length", "pr_alto_pico",
  "pr_beak_length", "pr_tarsus", "pr_skull_width"
)

model_table$min_normalization_parameters <-
  model_table$min_normalization_parameters[, no_intercept_variables]
colnames(model_table$min_normalization_parameters) <- c(
  "min_skull_length", "min_alto_pico", "min_beak_length", "min_tarsus", "min_skull_width"
)

model_table$max_normalization_parameters <-
  model_table$max_normalization_parameters[, no_intercept_variables]
colnames(model_table$max_normalization_parameters) <- c(
  "max_skull_length", "max_beak_height", "max_beak_length", "max_tarsus", "max_skull_width"
)

completed_table <- data.table(
  cbind(
    model_table$model_coefficients,
    threshold_error_table,
    model_table$min_normalization_parameters,
    model_table$max_normalization_parameters,
    model_table$standard_error,
    model_table$z_value,
    model_table$pr_value
  )
)

row_na <- apply(
  is.na(completed_table),
  MARGIN = 1,
  FUN = any
)
filtered_table <- completed_table[!row_na, ]
minimum_error <- min(filtered_table$error)
best_model_table <- filtered_table[error == minimum_error]

write_csv(
  best_model_table,
  paste0(results_path, "logistic_model_table.csv")
)
