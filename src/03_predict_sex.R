library(dimorfismo)
library(tidyverse)

tdp_path <- ("data/raw/")
csv_file <- file.path(tdp_path, "laysan_albatross_morphometry_guadalupe.csv")
csv_data <- data.table::data.table(read.csv(csv_file))
results_path <- "data/processed/"
json_file <- file.path(results_path, "best_logistic_model_parameters_laal_ig.json")
imported_table <- data.table::data.table(
  readr::read_csv(paste0(results_path, "best_models_table.csv"))
)

n_rows_table <- nrow(imported_table)
n_rows_data <- nrow(csv_data)
threshold <- as.numeric(imported_table[1, 7])
males <- c()

for (i_albatross in 1:n_rows_data) {
  data <- csv_data[i_albatross, ]
  dimorphism_model_albatross <- dimorphism_model$new()
  dimorphism_model_albatross$load_parameters(json_file)
  prob <- dimorphism_model_albatross$predict(data)
  males <- append(males, as.logical(prob > threshold))
}
