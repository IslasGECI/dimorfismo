

#' @export
regretion_to_data_frame <- function(regression) {
  regression_summary <- summary.glm(regression)
  regression_summary$coefficients <- round(regression_summary$coefficients, 3)
  data_frame <- as.data.frame(regression_summary$coefficients)
  data_frame <- cbind(rownames(data_frame), data_frame)
  colnames(data_frame)[1] <- "Variables"
  return(data_frame)
}

#' @export
fit_null_model <- function(normalized_data) {
  null_regression <- glm(
    formula = sexo ~ 1,
    data = normalized_data,
    family = "binomial"
  )
  return(null_regression)
}

#' @export
fit_complete_model <- function(normalized_data) {
  all_regression <- glm(
    formula = sexo ~ .,
    data = normalized_data,
    family = "binomial"
  )
  return(all_regression)
}

#' @export
fit_stepwise <- function(null, all) {
  step_regression <- stats::step(null,
    scope = list(
      lower = null,
      upper = all
    ),
    direction = "both",
    trace = 0
  )
  return(step_regression)
}

#' @export
line <- function(x) {
  return((3) + (5) * x)
}

#' @export
logt <- function(x) {
  probability <- 1 / (1 + exp(-line(x)))
  return(probability)
}

#' @export
get_best_json_for_logistic_model <- function(data_path, output_json_path) {
  final_y_test <- c()
  print("antes csv")
  data <- data.table(read_csv(data_path))
  n_data <- nrow(data)

  trainning_proportion <- 0.80

  variables_model <- c(
    "beak_height", "beak_length", "skull_length", "skull_width",
    "tarsus", "close_brim_length", "open_brim_length", "wingspan"
  )
  column_names <- c("(Intercept)", variables_model)
  num_repetitions <- 10
  threshold_error_table <- data.frame(threshold <- c(), error <- c())
  calculador_roc <- roc$new()

  null_frame <- data.frame(
    matrix(
      ncol = length(column_names),
      nrow = num_repetitions
    )
  )

  model_table <- list(
    model_coefficients = null_frame,
    standard_error = null_frame,
    z_value = null_frame,
    pr_value = null_frame,
    min_normalization_parameters = null_frame,
    max_normalization_parameters = null_frame
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

    setkey(trainning_data, id_darvic, vectors=TRUE)

    no_numerical_data <- trainning_data[unique(trainning_data),
      .SD[, !sapply(.SD, is.numeric), with = FALSE],
      mult = "last"
    ]

    numerical_data <- trainning_data[,
      lapply(.SD[, sapply(.SD, is.numeric), with = FALSE], mean),
      by = id_darvic
    ]
    averaged_data <- numerical_data[no_numerical_data[!duplicated(id_darvic)]]

    # Se definen variables para utilizarse en el texto que decribe los Datos.
    normalized_data <- averaged_data[!is.na(averaged_data$masa),
      variables_model,
      with = FALSE
    ]

    normalized_data <- as.data.frame(sapply(normalized_data, normalize))
    normalized_data$sexo <- averaged_data[!is.na(averaged_data$masa), ]$sexo
    normalized_data$sexo <- factor(normalized_data$sexo)

    null_regression <- fit_null_model(normalized_data)

    # Hacemos el modelos utilizando las 11 varibles
    all_regression <- fit_complete_model(normalized_data)

    # Aplicamos el método _stepwise_.
    step_regression <- fit_stepwise(null_regression, all_regression)

    normalized_data$id_darvic <- averaged_data[!is.na(averaged_data$masa), ]$id_darvic
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

    model_used_data <- averaged_data[!is.na(averaged_data$masa),
      model_varibles_names,
      with = FALSE
    ]
    min_normalized_data <- sapply(model_used_data, min)
    max_normalized_data <- sapply(model_used_data, max)

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

    readr::write_lines(
      jsonlite::toJSON(list_normalization_parameters, pretty = T),
      output_json_path
    )

  }
}
