library(data.table) 

source("R/Clases/ModeloDimorfismo.R")
source("R/Clases/CalculatorROC.R")
source("R/funciones/evaluate_model.R")
source("R/funciones/getPredictionSexPlot.R")
source("R/funciones/getSexProbabilityPlot.R")
source("R/funciones/regretion2DataFrameCoefficients.R")

directorioTDP <- ("inst/extdata/morfometria-albatros-laysan-guadalupe")
nombreArchivoCSV <- file.path(directorioTDP,"morfometria_albatros-laysan_guadalupe.csv")
nombreArchivoJSON <- file.path(directorioTDP,"datapackage.json")
rutaResultados = ('resultados/')

Metadatos <- jsonlite::fromJSON(nombreArchivoJSON)
Datos <- data.table(read.csv(nombreArchivoCSV))
n_datos <- nrow(Datos)

proporcion_entrenamiento <- 0.80
proporcion_validacion <- 1 - proporcion_entrenamiento

variablesParaModelo <- c("longitudCraneo", "longitudPico", "anchoCraneo", "altoPico", "tarso", "longAlaCerrada", "longAlaAbierta", "envergadura")
nombre_columnas <- c("(Intercept)", variablesParaModelo)
n_repeticiones <- 2000
#2000