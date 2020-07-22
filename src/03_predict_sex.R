library(dimorfismo)
library(tidyverse)

tdp_path <- ("data/raw/")
csv_file <- file.path(tdp_path, "laysan_albatross_morphometry_guadalupe.csv")
data <- data.table::data.table(read.csv(csv_file))
results_path <- "data/processed/"
imported_table <- data.table::data.table(
  readr::read_csv(paste0(results_path, "best_models_table.csv"))
)

calculador_roc <- roc$new()
n_rows_table <- nrow(imported_table)
n_rows_data <- nrow(data)

for (i_albatross in 1:n_rows_data) {
  dato <- data[i_albatross, ]
  males <- c()
  for (i_row in 1:n_rows_table) {
    auxiliar_coefficients_table <- imported_table[i_row, 1:5]
    auxiliar_coefficients_table <- data.frame(
      data.table::melt(auxiliar_coefficients_table),
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
      path = "data/processed/logistic_model_parameters.json"
    )

    dimorphism_model_albatross <- dimorphism_model$new()
    dimorphism_model_albatross$load_parameters("data/processed/logistic_model_parameters.json")
    prob <- dimorphism_model_albatross$predict(dato)
    males <- append(males, as.logical(prob > threshold))
  }

  print(
    paste(
      i_albatross,
      as.character(dato$sexo),
      sum(males) / length(males) * 100
    )
  )
}
