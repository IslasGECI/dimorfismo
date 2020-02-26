source("src/ModeloDimorfismo.R")
source("src/CalculatorROC.R")

directorioTDP <- ("data/raw")
nombreArchivoCSV <- file.path(directorioTDP,"morfometria_albatros-laysan_guadalupe.csv")

Datos <- data.table::data.table(read.csv(nombreArchivoCSV))

ruta_resultados <- "data/processed/"
tabla_importada <- data.table::data.table(readr::read_csv(paste0(ruta_resultados,"tabla_modelos_logisticos.csv")))
calculadorROC <- ROC$new()
n_renglones <- nrow(tabla_importada)
errores <- c()

for(i_renglon in 1:n_renglones) {
  tabla_coeficientes_auxiliar <- tabla_importada[i_renglon, 1:5]
  tabla_coeficientes_auxiliar <- data.frame(data.table::melt(tabla_coeficientes_auxiliar), row.names = colnames(tabla_coeficientes_auxiliar))
  colnames(tabla_coeficientes_auxiliar) <- c("Variables", "Estimate")
  umbral <- as.numeric(tabla_importada[i_renglon, 6])
  tabla_parametros_maximos_normalizacion_auxiliar <- tabla_importada[i_renglon, 12:15]
  colnames(tabla_parametros_maximos_normalizacion_auxiliar) <- rownames(tabla_coeficientes_auxiliar[2:5,])
  tabla_parametros_minimos_normalizacion_auxiliar <- tabla_importada[i_renglon, 8:11]
  colnames(tabla_parametros_minimos_normalizacion_auxiliar) <- rownames(tabla_coeficientes_auxiliar[2:5,])
  parametrosNormalizacion <- list(valorMinimo = as.list(tabla_parametros_minimos_normalizacion_auxiliar), 
                                  valorMaximo = as.list(tabla_parametros_maximos_normalizacion_auxiliar))
  listaParametrosModeloNormalizacion <- list(parametrosNormalizacion = parametrosNormalizacion, 
                                             parametrosModelo = tabla_coeficientes_auxiliar)
  
  readr::write_lines(jsonlite::toJSON(listaParametrosModeloNormalizacion, pretty = T), 
                     path =  "data/processed/parametros_modelo_logistico_laal_ig.json")
  ModeloDimorfismoAlbatros <- ModeloDimorfismo$new()
  ModeloDimorfismoAlbatros$loadParameters("data/processed/parametros_modelo_logistico_laal_ig.json")
  
  prob <- ModeloDimorfismoAlbatros$predict(Datos)
  y_test <- ifelse(Datos$sexo == 'M', 1, 0)
  datos_roc <- data.frame(y_test, prob)
  errores <- append(errores, calculadorROC$calculateError(datos_roc,umbral))
}

es_error_minimo <- errores == min(errores)
write_csv(tabla_importada[es_error_minimo,], paste0(ruta_resultados,'tabla_mejores_modelos.csv'))

readr::write_lines(jsonlite::toJSON(listaParametrosModeloNormalizacion, pretty = T), path =  "data/processed/parametros_mejor_modelo_logistico_laal_ig.json")