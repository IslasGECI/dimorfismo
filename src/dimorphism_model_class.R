library(R6)

ModeloDimorfismo <- R6Class("ModeloDimorfismo",
  public = list(
    loadParameters = function(JSONpath) {
      #escribir codigo para cargar los parametros
      # Importa parametrosModelo
      jsonParametros <- rjson::fromJSON(file = JSONpath)
      private$ParametrosNormalizacion <- jsonParametros$parametrosNormalizacion
      private$ParametrosModelo <- jsonParametros$parametrosModelo
    },
    predict = function(TablaDatosMorfometricos) {
      # escribir codigo para predecir sexo
      z <- private$getValue("(Intercept)")
      iVarible <- 1
      for (variable in private$ParametrosModelo) {
        if (variable$Variables != "(Intercept)") {
          columna <- TablaDatosMorfometricos[, variable$Variables, with = FALSE]
          minimo <- as.numeric(private$ParametrosNormalizacion$valorMinimo[variable$Variables])
          maximo <- as.numeric(private$ParametrosNormalizacion$valorMaximo[variable$Variables])

          normalize <- function(columna) {
            (columna - minimo)/(maximo - minimo)
          }

          ColumnaNormalizada <- as.data.frame(apply(columna, 2, normalize))
          z <- z + ColumnaNormalizada * private$getValue(variable$Variables)
          iVarible <- iVarible + 1
        }
      }
      probabilidad <- 1 / (1 + exp(-z))
      colnames(probabilidad) <- "probability"
      return(probabilidad)
    },
    getVariablesNames = function() {
      variablesModelo <- c()
      
      for (variable in private$ParametrosModelo) {
        if (variable$Variables != "(Intercept)") {
          variablesModelo <- c(variablesModelo, variable$Variables)
        }
      }
      return(variablesModelo)
    }
  ), 
  private = list(
    ParametrosModelo = NULL, 
    ParametrosNormalizacion = NULL, 
    getValue = function(nombreVariable) {
      for (variable in private$ParametrosModelo) {
        if (variable$Variables == nombreVariable) {
          return(variable$Estimate)
        }
      }
    }
  )
)