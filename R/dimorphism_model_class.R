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
      z <- private$get_value("(Intercept)")
      for (variable in private$model_parameters) {
        if (variable$Variables != "(Intercept)") {
          column <- morphometric_data_table[, variable$Variables]
          minimum <- as.numeric(private$normalization_parameters$minimum_value[variable$Variables])
          maximum <- as.numeric(private$normalization_parameters$maximum_value[variable$Variables])
          normalized_column <- as.data.frame(normalize(column, minimum, maximum))
          z <- z + normalized_column * private$get_value(variable$Variables)
        }
      }
      probability <- 1 / (1 + exp(-z))
      colnames(probability) <- "probability"
      return(probability)
    }
  ),

  private = list(
    model_parameters = NULL,
    normalization_parameters = NULL,

    get_value = function(variable_name) {
      for (variable in private$model_parameters) {
        if (variable$Variables == variable_name) {
          return(variable$Estimate)
        }
      }
    }
  )
)
