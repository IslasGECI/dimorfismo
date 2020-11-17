library(R6)
#' @source "R/normalize_function.R"
#' @export
dimorphism_model <- R6Class("dimorphism_model",
  public = list(
    load_parameters = function(json_path) {
      json_parameters <- rjson::fromJSON(file = json_path)
      private$normalization_parameters <- json_parameters$normalization_parameters
      private$model_parameters <- json_parameters$model_parameters
    },

    predict = function(morphometric_data_table) {
      z <- private$get_z_value(morphometric_data_table)
      probability <- 1 / (1 + exp(-z))
      colnames(probability) <- "probability"
      return(probability)
    }
  ),

  private = list(
    model_parameters = NULL,
    normalization_parameters = NULL,

    calculate_z = function(data_table, variable, z) {
      column <- data_table[, variable$Variables]
      normalized_column <- private$normalize_column(column, variable)
      z <- z + normalized_column * private$get_estimate_value(variable$Variables)
      return(z)
    },

    get_estimate_value = function(variable_name) {
      for (variable in private$model_parameters) {
        if (variable$Variables == variable_name) {
          return(variable$Estimate)
        }
      }
    },

    get_maximum = function(variable) {
      maximum <- as.numeric(private$normalization_parameters$maximum_value[variable$Variables])
      return(maximum)
    },

    get_minimum = function(variable) {
      minimum <- as.numeric(private$normalization_parameters$minimum_value[variable$Variables])
      return(minimum)
    },

    get_z_value = function(data_table) {
      z <- private$get_estimate_value("(Intercept)")
      morphometric_parameters <- private$remove_intercept()
      for (variable in morphometric_parameters) {
        z <- private$calculate_z(data_table, variable, z)
      }
      return(z)
    },

    normalize_column = function(column, variable) {
      minimum <- private$get_minimum(variable)
      maximum <- private$get_maximum(variable)
      normalized_column <- as.data.frame(normalize(column, minimum, maximum))
      return(normalized_column)
    },

    remove_intercept = function() {
      n_parameters <- length(private$model_parameters)
      morphometric_parameters <- private$model_parameters[2:n_parameters]
      return(morphometric_parameters)
    }
  )
)
