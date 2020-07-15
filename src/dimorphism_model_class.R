library(R6)

dimorphism_model <- R6Class("dimorphism_model",
  public = list(
    load_parameters = function(json_path) {
      # escribir codigo para cargar los parametros
      # Importa model_parameters
      json_parameters <- rjson::fromJSON(file = json_path)
      private$normalization_parameters <- json_parameters$normalization_parameters
      private$model_parameters <- json_parameters$model_parameters
    },
    predict = function(morphometric_data_table) {
      # escribir codigo para predecir Sexo
      z <- private$get_value("(Intercept)")
      i_variable <- 1
      for (variable in private$model_parameters) {
        if (variable$Variables != "(Intercept)") {
          column <- morphometric_data_table[, variable$Variables, with = FALSE]
          minimum <- as.numeric(private$normalization_parameters$minimum_value[variable$Variables])
          maximum <- as.numeric(private$normalization_parameters$maximum_value[variable$Variables])

          normalize <- function(column) {
            normalize_return <- (column - minimum) / (maximum - minimum)
            return(normalize_return)
          }

          normalized_column <- as.data.frame(apply(column, 2, normalize))
          z <- z + normalized_column * private$get_value(variable$Variables)
          i_variable <- i_variable + 1
        }
      }
      probability <- 1 / (1 + exp(-z))
      colnames(probability) <- "probability"
      return(probability)
    },
    get_variables_names = function() {
      model_variables <- c()
      for (variable in private$model_parameters) {
        if (variable$Variables != "(Intercept)") {
          model_variables <- c(model_variables, variable$Variables)
        }
      }
      return(model_variables)
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
