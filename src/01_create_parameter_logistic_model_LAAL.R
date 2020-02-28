library(data.table) 

source("src/dimorphism_model_class.R")
source("src/calculator_ROC_class.R")
source("src/evaluate_model_function.R")
source("src/get_prediction_sex_plot_function.R")
source("src/get_sex_probability_plot_function.R")
source("src/regretion_to_data_frame_coefficients_function.R")

directorioTDP <- ("data/raw/")
nombreArchivoCSV <- file.path(directorioTDP,"morfometria_albatros-laysan_guadalupe.csv")
nombreArchivoJSON <- file.path(directorioTDP,"datapackage.json")
rutaResultados = ('data/processed/')

Metadatos <- jsonlite::fromJSON(nombreArchivoJSON)
Datos <- data.table(read.csv(nombreArchivoCSV))
n_datos <- nrow(Datos)

proporcion_entrenamiento <- 0.80
proporcion_validacion <- 1 - proporcion_entrenamiento

variablesParaModelo <- c("longitudCraneo", "longitudPico", "anchoCraneo", "altoPico", "tarso", "longAlaCerrada", "longAlaAbierta", "envergadura")
nombre_columnas <- c("(Intercept)", variablesParaModelo)
n_repeticiones <- 10
#2000

tabla_umbral_error <- data.frame(umbral <- c(),error <- c())
calculadorROC <- ROC$new()

tabla_modelo <- list(coeficientes_modelo = data.frame(matrix(ncol = length(nombre_columnas), nrow = n_repeticiones)), 
                     error_estandar = data.frame(matrix(ncol = length(nombre_columnas), nrow = n_repeticiones)), 
                     valor_z = data.frame(matrix(ncol = length(nombre_columnas), nrow = n_repeticiones)), 
                     Pr = data.frame(matrix(ncol = length(nombre_columnas), nrow = n_repeticiones)), 
                     parametros_normalizacion_minimos = data.frame(matrix(ncol = length(nombre_columnas), nrow = n_repeticiones)), 
                     parametros_normalizacion_maximos = data.frame(matrix(ncol = length(nombre_columnas), nrow = n_repeticiones)))

colnames(tabla_modelo$coeficientes_modelo) <- nombre_columnas
colnames(tabla_modelo$error_estandar) <- nombre_columnas
colnames(tabla_modelo$valor_z) <- nombre_columnas
colnames(tabla_modelo$Pr) <- nombre_columnas
colnames(tabla_modelo$parametros_normalizacion_minimos) <- nombre_columnas
colnames(tabla_modelo$parametros_normalizacion_maximos) <- nombre_columnas

barra_progeso <- txtProgressBar(min = 0, max = n_repeticiones, style = 3)
for(i in 1:n_repeticiones) {
  indice_entrenamiento <- sample(1:n_datos, round(proporcion_entrenamiento*n_datos))
  indice_validacion <- -indice_entrenamiento
  
  # Se extraen los datos de 2015, 2016, 2017 ya que solo estos se usaran para crear el modelo
  datos_entrenamiento <- Datos[indice_entrenamiento]
  datos_validacion <- Datos[indice_validacion]
  
  setkey(datos_entrenamiento, darvic)
  individuosRepetidos <- data.table(darvic=datos_entrenamiento[duplicated(darvic)]$darvic)
  
  DatosNoNumericos <- datos_entrenamiento[unique(datos_entrenamiento), 
                                      .SD[, !sapply(.SD, is.numeric),with=FALSE], 
                                      mult="last"]
  DatosNumericos <- datos_entrenamiento[, 
                                    lapply(.SD[, sapply(.SD, is.numeric), with = FALSE], mean, na.rm=T), 
                                    by=darvic]
  DatosPromediados <- DatosNumericos[DatosNoNumericos[!duplicated(darvic)]]
  
  # Se definen variables para utilizarse en el texto que decribe los Datos.
  CamposMetaDatos <- data.table(Metadatos$resources$schema$fields[[1]])
  # Se identifican los `fields` en los Metadatos (son las variables de los Datos) con unidades definidas ya que estos (campos) describen a las variables morfométricas.
  esMedidaMorfometrica <- CamposMetaDatos$units!=""
  nVariablesMorfometricas <- sum(esMedidaMorfometrica)
  # Se obtienen el nombre largo de las variables morfométricas
  nombresLargosMorfometria <- CamposMetaDatos[esMedidaMorfometrica,nombre_largo]
  #listaVariablesMorfometricas <- tolower(paste0(nombresLargosMorfometria[1], paste(", ", nombresLargosMorfometria[2:(nVariablesMorfometricas-1)], collapse = ""), " y ", nombresLargosMorfometria[nVariablesMorfometricas]))
  nIndividuos <- length(unique(DatosPromediados$darvic))
  
  DatosNormalizados <- DatosPromediados[!is.na(DatosPromediados$peso), variablesParaModelo, with=FALSE]
  normalize <- function(columna) (columna - min(columna))/(max(columna)-min(columna))
  DatosNormalizados <- as.data.frame(apply(DatosNormalizados,2,normalize))
  DatosNormalizados$sexo <- DatosPromediados[!is.na(DatosPromediados$peso),]$sexo
  
  RegresionNula <- glm(formula = sexo ~ 1, data = DatosNormalizados, family = "binomial")
  # Hacemos el modelos utilizando las 11 varibles
  RegresionTodas <- glm(formula = sexo ~ ., data = DatosNormalizados, family = "binomial")
  # Aplicamos el método _stepwise_.  
  RegresionStep <- step(RegresionNula, scope = list(lower = RegresionNula, upper = RegresionTodas), direction = "both", trace = 0)
  DatosNormalizados$darvic <- DatosPromediados[!is.na(DatosPromediados$peso),]$darvic
  
  CoeficientesStep  <- regretion2DataFrameCoefficients(RegresionStep)
  
  ##
  for(i_coeficiente in rownames(CoeficientesStep)){
    tabla_modelo$coeficientes_modelo[i, i_coeficiente] <- CoeficientesStep[i_coeficiente, "Estimate"]
    tabla_modelo$error_estandar[i, i_coeficiente] <- CoeficientesStep[i_coeficiente, "Std. Error"]
    tabla_modelo$valor_z[i, i_coeficiente] <- CoeficientesStep[i_coeficiente, "z value"]
    tabla_modelo$Pr[i, i_coeficiente] <- CoeficientesStep[i_coeficiente, "Pr(>|z|)"]
  }
  ##


  #Crea un JSON como una lista de los parametros anteriores
  nombresVariablesModelo <- names(RegresionStep$coefficients)
  nombresVariablesModelo <- nombresVariablesModelo[nombresVariablesModelo != "(Intercept)"]
  

  DatosUtilizadosModelo <- DatosPromediados[!is.na(DatosPromediados$peso), nombresVariablesModelo, with=FALSE]
  minimo_datos_normalizacion <- apply(DatosUtilizadosModelo,2,min)
  maximo_datos_normalizacion <- apply(DatosUtilizadosModelo,2,max)
  
  parametrosNormalizacion <- list(
    valorMinimo = split(unname(minimo_datos_normalizacion),names(minimo_datos_normalizacion)), 
    valorMaximo = split(unname(maximo_datos_normalizacion),names(maximo_datos_normalizacion))
  )
  listaParametrosModeloNormalizacion <- list(
    parametrosNormalizacion = parametrosNormalizacion,
    parametrosModelo = CoeficientesStep
  )

  ##
  for(i_par_normalizacion in colnames(DatosUtilizadosModelo)){
    tabla_modelo$parametros_normalizacion_minimos[i, i_par_normalizacion] <- minimo_datos_normalizacion[i_par_normalizacion]
    tabla_modelo$parametros_normalizacion_maximos[i, i_par_normalizacion] <- maximo_datos_normalizacion[i_par_normalizacion]
  }
  ##
  
  
  readr::write_lines(jsonlite::toJSON(listaParametrosModeloNormalizacion, pretty = T), path =  "data/processed/parametros_modelo_logistico_laal_ig.json")
  ModeloDimorfismoAlbatros <- ModeloDimorfismo$new()
  ModeloDimorfismoAlbatros$loadParameters("data/processed/parametros_modelo_logistico_laal_ig.json")

  prob <- ModeloDimorfismoAlbatros$predict(datos_validacion)
  y_test <- ifelse(datos_validacion$sexo == 'M', 1, 0)
  datos_roc <- data.frame(y_test, prob)
  criterio_error <- calculadorROC$getBestThresholdAndError(datos_roc)
  tabla_umbral_error <- rbind(tabla_umbral_error, criterio_error)
  setTxtProgressBar(barra_progeso, i)
}
close(barra_progeso)

variables_finales <- c("(Intercept)", "longitudCraneo", "altoPico", "longitudPico", "tarso", "anchoCraneo")
variables_sin_intercepto <- c("longitudCraneo", "altoPico", "longitudPico", "tarso", "anchoCraneo")

tabla_modelo$coeficientes_modelo <- tabla_modelo$coeficientes_modelo[, variables_finales]

tabla_modelo$error_estandar <- tabla_modelo$error_estandar[, variables_finales]
colnames(tabla_modelo$error_estandar) <- c("stdErrIntercept","stdErrlongitudCraneo","stdErrAltoPico", "stdErrLongitudPico", "stdErrTarso", "stdErrAnchoCraneo")

tabla_modelo$valor_z <- tabla_modelo$valor_z[, variables_finales]
colnames(tabla_modelo$valor_z) <- c("zValueIntercept","zValuelongitudCraneo","zValueAltoPico", "zValueLongitudPico", "zValueTarso", "zValueAnchoCraneo")

tabla_modelo$Pr <- tabla_modelo$Pr[, variables_finales]
colnames(tabla_modelo$Pr) <- c("PrIntercept","PrlongitudCraneo","PrAltoPico", "PrLongitudPico", "PrTarso", "PrAnchoCraneo")

tabla_modelo$parametros_normalizacion_minimos <- tabla_modelo$parametros_normalizacion_minimos[, variables_sin_intercepto]
colnames(tabla_modelo$parametros_normalizacion_minimos) <- c("minlongitudCraneo","minAltoPico", "minLongitudPico", "minTarso", "minAnchoCraneo")

tabla_modelo$parametros_normalizacion_maximos <- tabla_modelo$parametros_normalizacion_maximos[, variables_sin_intercepto]
colnames(tabla_modelo$parametros_normalizacion_maximos) <- c("maxlongitudCraneo","maxAltoPico", "maxLongitudPico", "maxTarso", "maxAnchoCraneo")

tabla_completa <- data.table(cbind(tabla_modelo$coeficientes_modelo, tabla_umbral_error, tabla_modelo$parametros_normalizacion_minimos, 
                        tabla_modelo$parametros_normalizacion_maximos, tabla_modelo$error_estandar, tabla_modelo$valor_z, 
                        tabla_modelo$Pr))


es_renglon_na <- apply(is.na(tabla_completa), MARGIN = 1, FUN = any)
tabla_filtrada <- tabla_completa[!es_renglon_na, ]
error_minimo <- min(tabla_filtrada$error)
tabla_mejores_modelos <- tabla_filtrada[error == error_minimo]
 

write_csv(tabla_mejores_modelos, paste0(rutaResultados,'tabla_modelos_logisticos.csv'))