# Importa parametrosModelo
library(data.table)

evaluate_model <- function(datos_entrenamiento, datos_validacion) {
  
  ModeloDimorfismoAlbatros <- ModeloDimorfismo$new()
  ModeloDimorfismoAlbatros$loadParameters("src/R/resultados/parametros_modelo_logistico_laal_ig.json")
  probabilidad_macho_entrenamiento <- ModeloDimorfismoAlbatros$predict(datos_entrenamiento)
  probabilidad_macho_validacion <- ModeloDimorfismoAlbatros$predict(datos_validacion)
  
  prediccion_entrenamiento <- probabilidad_macho_entrenamiento
  prediccion_validacion <- probabilidad_macho_validacion
  
  es_macho_entrenamiento <- probabilidad_macho_entrenamiento > 0.5
  es_macho_validacion <- probabilidad_macho_validacion > 0.5
  
  prediccion_entrenamiento[es_macho_entrenamiento] = 1
  prediccion_validacion[es_macho_validacion] = 1
  
  prediccion_entrenamiento[!es_macho_entrenamiento] = 0
  prediccion_validacion[!es_macho_validacion] = 0
  
  correcto_entrenamiento <- (es_macho_entrenamiento & datos_entrenamiento$sexo == "M") | (!es_macho_entrenamiento & datos_entrenamiento$sexo == "H")
  correcto_validacion <- (es_macho_validacion & datos_validacion$sexo == "M") | (!es_macho_validacion & datos_validacion$sexo == "H")
  
  error_todas_entrenamiento <- round(sum(correcto_entrenamiento/length(datos_entrenamiento$sexo))*100)
  error_todas_validacion <- round(sum(correcto_validacion/length(datos_validacion$sexo))*100)
  
  listaError <- list(erros_variables_entrenamiento = error_todas_entrenamiento, error_variables_validacion = error_todas_validacion)
  
  readr::write_lines(jsonlite::toJSON(listaError), path = "scr/R/resultados/error_calculado.json")
}