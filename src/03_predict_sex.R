source("src/dimorphism_model_class.R")
source("src/calculator_ROC_class.R")

TDP_path <- ("data/raw/")
csv_file <- file.path(TDP_path, "morfometria_albatros-laysan_guadalupe.csv")

data <- data.table::data.table(read.csv(csv_file))

ruta_resultados <- "data/processed/"
tabla_importada <- data.table::data.table(readr::read_csv(
                                paste0(ruta_resultados, "tabla_mejores_modelos.csv")))
calculador_ROC <- ROC$new()
n_renglones <- nrow(tabla_importada)

for (i_albatros in 1:nrow(data)) {
    dato <- data[i_albatros,]
    es_macho <- c()
    for (i_renglon in 1:n_renglones) {
        tabla_coeficientes_auxiliar <- tabla_importada[i_renglon, 1:5]
        tabla_coeficientes_auxiliar <- data.frame(data.table::melt(tabla_coeficientes_auxiliar), 
                                                    row.names = colnames(tabla_coeficientes_auxiliar))
        colnames(tabla_coeficientes_auxiliar) <- c("Variables", "Estimate")
        threshold <- as.numeric(tabla_importada[i_renglon, 6])
        tabla_parametros_maximos_normalizacion_auxiliar <- tabla_importada[i_renglon, 12:15]
        colnames(tabla_parametros_maximos_normalizacion_auxiliar) <- rownames(tabla_coeficientes_auxiliar[2:5,])
        tabla_parametros_minimos_normalizacion_auxiliar <- tabla_importada[i_renglon, 8:11]
        colnames(tabla_parametros_minimos_normalizacion_auxiliar) <- rownames(tabla_coeficientes_auxiliar[2:5,])
        normalization_parameters <- list(minimum_value = as.list(tabla_parametros_minimos_normalizacion_auxiliar), 
                                        maximum_value = as.list(tabla_parametros_maximos_normalizacion_auxiliar))
        list_parameters_normalization <- list(normalization_parameters = normalization_parameters, 
                                                    model_parameters = tabla_coeficientes_auxiliar)
        
        readr::write_lines(
            jsonlite::toJSON(list_parameters_normalization, pretty = T), 
            path = "data/processed/parametros_modelo_logistico_laal_ig.json"
        )
        dimorphism_model_albatross <- dimorphism_model$new()
        dimorphism_model_albatross$load_parameters("data/processed/parametros_modelo_logistico_laal_ig.json")
        
        prob <- dimorphism_model_albatross$predict(dato)
        es_macho <- append(es_macho, as.logical(prob > threshold))
    }
    print(paste(i_albatros, 
            as.character(dato$sexo), 
            sum(es_macho) / length(es_macho) * 100)
    )
}