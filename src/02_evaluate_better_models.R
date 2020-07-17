source("src/dimorphism_model_class.R")
source("src/calculator_ROC_class.R")

tdp_path <- ("data/raw")
json_path <- ("data/processed/logistic_model_parameters.json")
csv_file <- file.path(tdp_path, "laysan_albatross_morphometry_guadalupe.csv")

data <- data.table::data.table(read.csv(csv_file))

results_path <- "data/processed/"
imported_table <- data.table::data.table(
  readr::read_csv(
    paste0(results_path, "logistic_model_table.csv")
  )
)
calculador_roc <- roc$new()
n_rows_table <- nrow(imported_table)
bugs <- c()

for (i_row in 1:n_rows_table) {
  auxiliar_coefficients_table <- imported_table[i_row, 1:5]
  auxiliar_coefficients_table <- data.frame(data.table::melt(
    auxiliar_coefficients_table
  ),
  row.names = colnames(auxiliar_coefficients_table)
  )
  colnames(auxiliar_coefficients_table) <- c("Variables", "Estimate")
  threshold <- as.numeric(imported_table[i_row, 7])
  max_auxiliar_normalized_table <- imported_table[i_row, 14:17]
  colnames(max_auxiliar_normalized_table) <- rownames(auxiliar_coefficients_table[2:5, ])
  min_auxiliar_normalized_table <- imported_table[i_row, 9:12]
  colnames(min_auxiliar_normalized_table) <- rownames(auxiliar_coefficients_table[2:5, ])
  normalization_parameters <- list(
    minimum_value = as.list(min_auxiliar_normalized_table),
    maximum_value = as.list(max_auxiliar_normalized_table)
  )
  list_normalization_parameters <- list(
    normalization_parameters = normalization_parameters,
    model_parameters = auxiliar_coefficients_table
  )

  readr::write_lines(
    jsonlite::toJSON(list_normalization_parameters, pretty = T),
    path = json_path
  )

  dimorphism_model_albatross <- dimorphism_model$new()
  dimorphism_model_albatross$load_parameters(json_path)

  prob <- dimorphism_model_albatross$predict(data)
  y_test <- ifelse(data$sexo == "M", 1, 0)
  roc_data <- data.frame(y_test, prob)
  bugs <- append(bugs, calculador_roc$calculate_error(roc_data, threshold))
}

minimun_error <- bugs == min(bugs)

write_csv(
  imported_table[minimun_error, ],
  paste0(results_path, "best_models_table.csv")
)

readr::write_lines(
  jsonlite::toJSON(list_normalization_parameters, pretty = T),
  path = "data/processed/best_logistic_model_parameters_laal_ig.json"
)
