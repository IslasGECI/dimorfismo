source("src/dimorphism_model_class.R")
source("src/calculator_ROC_class.R")

directorioTDP <- ("data/raw")
jsonParametroModelo <- ("data/processed/parametros_modelo_logistico_laal_ig.json")
nombreArchivoCSV <- file.path(directorioTDP, "morfometria_albatros-laysan_guadalupe.csv")

data <- data.table::data.table(read.csv(nombreArchivoCSV))

ruta_resultados <- "data/processed/"
tabla_importada <- data.table::data.table(
                    readr::read_csv(paste0(ruta_resultados,
                            "tabla_modelos_logisticos.csv"))
                    )
calculadorROC <- ROC$new()
n_renglones <- nrow(tabla_importada)
errores <- c()

for (i_renglon in 1:n_renglones) {
  tabla_coeficientes_auxiliar <- tabla_importada[i_renglon, 1:5]
  tabla_coeficientes_auxiliar <- data.frame(data.table::melt(
                                              tabla_coeficientes_auxiliar), 
                                              row.names = colnames(tabla_coeficientes_auxiliar)
                                            )
  colnames(tabla_coeficientes_auxiliar) <- c("Variables", "Estimate")
  threshold <- as.numeric(tabla_importada[i_renglon, 6])
  tabla_parametros_maximos_normalizacion_auxiliar <- tabla_importada[i_renglon, 12:15]
  colnames(tabla_parametros_maximos_normalizacion_auxiliar) <- rownames(tabla_coeficientes_auxiliar[2:5,])
  tabla_parametros_minimos_normalizacion_auxiliar <- tabla_importada[i_renglon, 8:11]
  colnames(tabla_parametros_minimos_normalizacion_auxiliar) <- rownames(tabla_coeficientes_auxiliar[2:5,])
  normalization_parameters <- list(minimum_value = as.list(tabla_parametros_minimos_normalizacion_auxiliar), 
                                  maximum_value = as.list(tabla_parametros_maximos_normalizacion_auxiliar))
  listaParametrosModeloNormalizacion <- list(normalization_parameters = normalization_parameters, 
                                             model_parameters = tabla_coeficientes_auxiliar)

  readr::write_lines(
    jsonlite::toJSON(listaParametrosModeloNormalizacion, pretty = T), 
    path = jsonParametroModelo
  )

  ModeloDimorfismoAlbatros <- dimorphism_model$new()
  ModeloDimorfismoAlbatros$load_parameters(jsonParametroModelo)

  prob <- ModeloDimorfismoAlbatros$predict(data)
  y_test <- ifelse(data$sexo == 'M', 1, 0)
  datos_roc <- data.frame(y_test, prob)
  errores <- append(errores, calculadorROC$calculate_error(datos_roc, threshold))
}

es_error_minimo <- errores == min(errores)
write_csv(tabla_importada[es_error_minimo, ],
  paste0(ruta_resultados,'tabla_mejores_modelos.csv')
)

readr::write_lines(
  jsonlite::toJSON(listaParametrosModeloNormalizacion, pretty = T), 
  path = "data/processed/parametros_mejor_modelo_logistico_laal_ig.json"
)