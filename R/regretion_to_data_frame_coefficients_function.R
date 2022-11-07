

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
fit_stepwise <- function(normalized_data) {
  null <- glm(
    formula = sexo ~ 1,
    data = normalized_data,
    family = "binomial"
  )
  all <- glm(
    formula = sexo ~ .,
    data = normalized_data,
    family = "binomial"
  )
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

make_empty_dataframe <- function(n_row, n_col) {
  empty_dataframe <- data.frame(
    matrix(
      ncol = n_col,
      nrow = n_row
    )
  )
  return(empty_dataframe)
}

make_null_modeltable <- function(null_frame) {
  empty_model_table <- list(
    model_coefficients = null_frame,
    standard_error = null_frame,
    z_value = null_frame,
    pr_value = null_frame,
    min_normalization_parameters = null_frame,
    max_normalization_parameters = null_frame
  )
  return(empty_model_table)
}

rename_model_table <- function(model_table) {
  variable_names <- c(
    "(Intercept)", "bill_depth", "bill_length", "head_length", "head_width",
    "Tarsus", "closed_wing_length", "open_wing_length", "wingspan"
  )
  colnames(model_table$model_coefficients) <- variable_names
  colnames(model_table$standard_error) <- variable_names
  colnames(model_table$z_value) <- variable_names
  colnames(model_table$pr_value) <- variable_names
  colnames(model_table$min_normalization_parameters) <- variable_names
  colnames(model_table$max_normalization_parameters) <- variable_names
  return(model_table)
}

get_progress_bar <- function(num_repetitions) {
  progress_bar <- txtProgressBar(
    min = 0,
    max = num_repetitions,
    style = 3
  )
  return(progress_bar)
}

get_trainning_index <- function(data) {
  n_data <- nrow(data)
  trainning_proportion <- 0.80
  trainning_index <- sample(1:n_data, round(trainning_proportion * n_data))
  return(trainning_index)
}

get_no_numerical_data <- function(trainning_data) {
  no_numerica_data <- trainning_data %>%
    select(subcolonia, id_darvic, sexo) %>%
    unique()
  return(no_numerica_data)
}

get_numerical_data <- function(trainning_data) {
  numerical_data <- trainning_data %>%
    select(id_darvic, temporada, id_nido, head_length, bill_length, longitud_narina, head_width, bill_depth, ancho_pico, Tarsus, closed_wing_length, open_wing_length, half_wingspan, wingspan, masa) %>%
    unique()
  return(numerical_data)
}

add_sex_to_data <- function(trainning_data) {
  numerical_data <- get_numerical_data(trainning_data)
  no_numerical_data <- get_no_numerical_data(trainning_data)
  no_duplicate_sex <- no_numerical_data[!duplicated(no_numerical_data$id_darvic), ]$sexo
  numerical_data_with_sex <- numerical_data %>% mutate(sexo = no_duplicate_sex)
  return(numerical_data_with_sex) # average
}

delete_NA_from_column <- function(numerical_data_with_sex, variables_model) {
  # Se definen variables parSa utilizarse en el texto que decribe los Datos.
  without_NA_data <- numerical_data_with_sex[!is.na(numerical_data_with_sex$masa),
    variables_model,
    with = FALSE
  ]
  return(without_NA_data) # normalized
}

get_normalize_data <- function(data_set_for_model, numerical_data_with_sex) {
  normalized_data <- as.data.frame(sapply(data_set_for_model, normalize))
  normalized_data$sexo <- numerical_data_with_sex[!is.na(numerical_data_with_sex$masa), ]$sexo
  normalized_data$sexo <- factor(normalized_data$sexo)
  return(normalized_data)
}

#' @export
get_best_json_for_logistic_model <- function(data_path, output_json_path) {
  final_y_test <- c()
  data <- data.table(read_csv(data_path))

  variables_model <- c(
    "bill_depth", "bill_length", "head_length", "head_width",
    "Tarsus", "closed_wing_length", "open_wing_length", "wingspan"
  )
  column_names <- c("(Intercept)", variables_model)
  num_repetitions <- 10
  threshold_error_table <- data.frame(threshold <- c(), error <- c())
  calculador_roc <- roc$new()

  null_frame <- make_empty_dataframe(num_repetitions, length(column_names))

  model_table <- make_null_modeltable(null_frame)

  model_table <- rename_model_table(model_table)

  progress_bar <- get_progress_bar(num_repetitions)

  trainning_index <- get_trainning_index(data)
  validation_index <- -trainning_index

  # Se extraen los datos de 2015, 2016, 2017 ya que sólo estos se usaran para crear el modelo

  trainning_data <- data[trainning_index, ]
  validation_data <- data[validation_index, ]
  write_csv(trainning_data, "trainning_data.csv")
  setkey(trainning_data, id_darvic)

  # Se definen variables para utilizarse en el texto que decribe los Datos.
  numerical_data_with_sex <- add_sex_to_data(trainning_data)

  data_set_for_model <- delete_NA_from_column(variable_names)

  normalized_data <- get_normalize_data(data_set_for_model, numerical_data_with_sex)

  null_regression <- fit_null_model(normalized_data)

  # Hacemos el modelos utilizando las 11 varibles
  all_regression <- fit_complete_model(normalized_data)

  # Aplicamos el método _stepwise_.
  step_regression <- fit_stepwise(normalized_data)

  normalized_data$id_darvic <- numerical_data_with_sex[!is.na(numerical_data_with_sex$masa), ]$id_darvic
  step_coefficients <- regretion_to_data_frame(step_regression)

  for (i in 1:num_repetitions) {
    for (i_coeficiente in rownames(step_coefficients)) {
      model_table$model_coefficients[i, i_coeficiente] <- step_coefficients[i_coeficiente, "Estimate"]
      model_table$standard_error[i, i_coeficiente] <- step_coefficients[i_coeficiente, "Std. Error"]
      model_table$z_value[i, i_coeficiente] <- step_coefficients[i_coeficiente, "z value"]
      model_table$pr_value[i, i_coeficiente] <- step_coefficients[i_coeficiente, "Pr(>|z|)"]
    }

    # Crea un JSON como una lista de los parametros anteriores
    model_varibles_names <- names(step_regression$coefficients)
    model_varibles_names <- model_varibles_names[model_varibles_names != "(Intercept)"]

    model_used_data <- numerical_data_with_sex[!is.na(numerical_data_with_sex$masa),
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
