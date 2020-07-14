source("src/dimorphism_model_class.R")
source("src/calculator_ROC_class.R")

tdp_path <- ("data/raw")
json_path <- ("data/processed/parametros_modelo_logistico_laal_ig.json")
csv_file <- file.path(tdp_path, "morfometria_albatros-laysan_guadalupe.csv")

data <- data.table::data.table(read.csv(csv_file))

results_path <- "data/processed/"
imported_table <- data.table::data.table(
                    readr::read_csv(
                      paste0(results_path, "tabla_modelos_logisticos.csv")
                    )
)
calculador_ROC <- ROC$new()
n_rows <- nrow(imported_table)
bugs <- c()

for (i_row in 1:n_rows) {
  auxiliar_coefficients_table <- imported_table[i_row, 1:5]
  auxiliar_coefficients_table <- data.frame(data.table::melt(
                                              auxiliar_coefficients_table),
                                              row.names = colnames(auxiliar_coefficients_table)
  )
  colnames(auxiliar_coefficients_table) <- c("Variables", "Estimate")
  threshold <- as.numeric(imported_table[i_row, 6])
  max_auxiliar_normalized_parameters_table <- imported_table[i_row, 12:15]
  colnames(max_auxiliar_normalized_parameters_table) <- rownames(auxiliar_coefficients_table[2:5,])
  min_auxiliar_normalized_parameters_table <- imported_table[i_row, 8:11]
  colnames(min_auxiliar_normalized_parameters_table) <- rownames(auxiliar_coefficients_table[2:5,])
  normalization_parameters <- list(
                                minimum_value = as.list(min_auxiliar_normalized_parameters_table),
                                maximum_value = as.list(max_auxiliar_normalized_parameters_table)
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
  y_test <- ifelse(data$Sexo == 'M', 1, 0)
  roc_data <- data.frame(y_test, prob)
  bugs <- append(bugs, calculador_ROC$calculate_error(roc_data, threshold))
}

minimun_error <- bugs == min(bugs)

write_csv(
  imported_table[minimun_error,],
  paste0(results_path, 'tabla_mejores_modelos.csv')
)

readr::write_lines(
  jsonlite::toJSON(list_normalization_parameters, pretty = T),
  path = "data/processed/parametros_mejor_modelo_logistico_laal_ig.json"
)