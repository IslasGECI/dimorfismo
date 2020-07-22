library(data.table)
library(dimorfismo)

set.seed(28)

tdp_path <- ("data/raw/")
results_path <- ("data/processed/")
csv_file <- file.path(tdp_path, "laysan_albatross_morphometry_guadalupe.csv")
json_file <- file.path(tdp_path, "datapackage.json")

metadata <- jsonlite::fromJSON(json_file)
data <- data.table(read.csv(csv_file))
n_data <- nrow(data)

trainning_proportion <- 0.80
validation_proportion <- 1 - trainning_proportion

variables_model <- c(
  "longitud_craneo", "longitud_pico", "ancho_craneo", "altura_pico",
  "tarso", "longitud_ala_cerrada", "longitud_ala_abierta", "envergadura"
)
column_names <- c("(Intercept)", variables_model)
num_repetitions <- 10
threshold_error_table <- data.frame(threshold <- c(), error <- c())
calculador_roc <- roc$new()

model_table <- list(
  model_coefficients = data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  ),
  standard_error = data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  ),
  z_value = data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  ),
  pr_value = data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  ),
  min_normalization_parameters = data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  ),
  max_normalization_parameters = data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  )
)

colnames(model_table$model_coefficients) <- column_names
colnames(model_table$standard_error) <- column_names
colnames(model_table$z_value) <- column_names
colnames(model_table$pr_value) <- column_names
colnames(model_table$min_normalization_parameters) <- column_names
colnames(model_table$max_normalization_parameters) <- column_names

progress_bar <- txtProgressBar(
  min = 0,
  max = num_repetitions,
  style = 3
)


for (i in 1:num_repetitions) {
  trainning_index <- sample(1:n_data, round(trainning_proportion * n_data))
  validation_index <- -trainning_index

  # Se extraen los datos de 2015, 2016, 2017 ya que sólo estos se usaran para crear el modelo
  trainning_data <- data[trainning_index]
  validation_data <- data[validation_index]

  setkey(trainning_data, id_darvic)
  repeated_individuals <- data.table(id_darvic = trainning_data[duplicated(id_darvic)]$id_darvic)

  no_numerical_data <- trainning_data[unique(trainning_data),
    .SD[, !sapply(.SD, is.numeric), with = FALSE],
    mult = "last"
  ]

  numerical_data <- trainning_data[,
    lapply(.SD[, sapply(.SD, is.numeric), with = FALSE], mean, na.rm = T),
    by = id_darvic
  ]
  averaged_data <- numerical_data[no_numerical_data[!duplicated(id_darvic)]]

  # Se definen variables para utilizarse en el texto que decribe los Datos.
  metadata_fields <- data.table(metadata$resources$schema$fields[[1]])
  # Se identifican los `fields` en los metadata (son las variables de los Datos)
  # con unidades definidas ya que estos (campos) describen a las variables morfométricas.
  morphometric_measurement <- metadata_fields$units != ""
  n_morphometric_variables <- sum(morphometric_measurement)
  # Se obtienen el nombre largo de las variables morfométricas
  large_names_morphometry <- metadata_fields[morphometric_measurement, nombre_largo]
  n_individuals <- length(unique(averaged_data$id_darvic))
  normalized_data <- averaged_data[!is.na(averaged_data$peso),
    variables_model,
    with = FALSE
  ]

  normalize <- function(column) {
    normalize_return <- (column - min(column)) / (max(column) - min(column))
    return(normalize_return)
  }

  normalized_data <- as.data.frame(apply(normalized_data, 2, normalize))
  normalized_data$sexo <- averaged_data[!is.na(averaged_data$peso), ]$sexo

  null_regression <- glm(
    formula = sexo ~ 1,
    data = normalized_data,
    family = "binomial"
  )

  # Hacemos el modelos utilizando las 11 varibles
  all_regression <- glm(
    formula = sexo ~ .,
    data = normalized_data,
    family = "binomial"
  )
  # Aplicamos el método _stepwise_.
  step_regression <- step(null_regression,
    scope = list(
      lower = null_regression,
      upper = all_regression
    ),
    direction = "both",
    trace = 0
  )

  normalized_data$id_darvic <- averaged_data[!is.na(averaged_data$peso), ]$id_darvic
  step_coefficients <- regretion_to_data_frame(step_regression)

  for (i_coeficiente in rownames(step_coefficients)) {
    model_table$model_coefficients[i, i_coeficiente] <- step_coefficients[i_coeficiente, "Estimate"]
    model_table$standard_error[i, i_coeficiente] <- step_coefficients[i_coeficiente, "Std. Error"]
    model_table$z_value[i, i_coeficiente] <- step_coefficients[i_coeficiente, "z value"]
    model_table$pr_value[i, i_coeficiente] <- step_coefficients[i_coeficiente, "Pr(>|z|)"]
  }

  # Crea un JSON como una lista de los parametros anteriores
  model_varibles_names <- names(step_regression$coefficients)
  model_varibles_names <- model_varibles_names[model_varibles_names != "(Intercept)"]

  model_used_data <- averaged_data[!is.na(averaged_data$peso),
    model_varibles_names,
    with = FALSE
  ]
  min_normalized_data <- apply(model_used_data, 2, min)
  max_normalized_data <- apply(model_used_data, 2, max)

  normalization_parameters <- list(
    minimum_value = split(
      unname(min_normalized_data),
      names(min_normalized_data)
    ),
    maximum_value = split(
      unname(max_normalized_data),
      names(max_normalized_data)
    )
  )

  list_normalization_parameters <- list(
    normalization_parameters = normalization_parameters,
    model_parameters = step_coefficients
  )

  for (i_pair_normalization in colnames(model_used_data)) {
    model_table$min_normalization_parameters[i, i_pair_normalization] <-
      min_normalized_data[i_pair_normalization]
    model_table$max_normalization_parameters[i, i_pair_normalization] <-
      max_normalized_data[i_pair_normalization]
  }

  json_path <- "data/processed/logistic_model_parameters.json"
  readr::write_lines(
    jsonlite::toJSON(list_normalization_parameters, pretty = T),
    json_path
  )

  dimorphism_model_albatross <- dimorphism_model$new()
  dimorphism_model_albatross$load_parameters(json_path)
  prob <- dimorphism_model_albatross$predict(validation_data)
  y_test <- ifelse(validation_data$sexo == "M", 1, 0)
  roc_data <- data.frame(y_test, prob)
  error_criteria <- calculador_roc$best_threshold_error(roc_data)
  threshold_error_table <- rbind(threshold_error_table, error_criteria)
  setTxtProgressBar(progress_bar, i)
}
close(progress_bar)

final_variables <- c(
  "(Intercept)", "longitud_craneo", "altura_pico",
  "longitud_pico", "tarso", "ancho_craneo"
)
no_intercept_variables <- c(
  "longitud_craneo", "altura_pico", "longitud_pico",
  "tarso", "ancho_craneo"
)

model_table$model_coefficients <- model_table$model_coefficients[, final_variables]

model_table$standard_error <- model_table$standard_error[, final_variables]
colnames(model_table$standard_error) <- c(
  "error_std_intercept", "error_std_longitud_craneo", "error_std_alto_pico",
  "error_std_longitud_pico", "error_std_tarso", "error_std_ancho_craneo"
)

model_table$z_value <- model_table$z_value[, final_variables]
colnames(model_table$z_value) <- c(
  "valor_z_intercept", "valor_z_longitud_craneo", "valor_z_altura_pico",
  "valor_z_longitud_pico", "valor_z_tarso", "valor_z_ancho_craneo"
)

model_table$pr_value <- model_table$pr_value[, final_variables]
colnames(model_table$pr_value) <- c(
  "pr_intercept", "pr_longitud_craneo", "pr_alto_pico",
  "pr_longitud_pico", "pr_tarso", "pr_ancho_craneo"
)

model_table$min_normalization_parameters <-
  model_table$min_normalization_parameters[, no_intercept_variables]
colnames(model_table$min_normalization_parameters) <- c(
  "min_longitud_craneo", "min_alto_pico", "min_longitud_pico", "min_tarso", "min_ancho_craneo"
)

model_table$max_normalization_parameters <-
  model_table$max_normalization_parameters[, no_intercept_variables]
colnames(model_table$max_normalization_parameters) <- c(
  "max_longitud_craneo", "max_altura_pico", "max_longitud_pico", "max_tarso", "max_ancho_craneo"
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
