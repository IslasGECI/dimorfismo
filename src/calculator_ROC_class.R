library(R6)
library(tidyverse)

ROC <- R6Class("ROC",
  public = list(
    rOC = NULL,
    initialize = function() {
    },

    getBestThresholdAndError = function(datos) {
        self$rOC <- private$calculateROC(datos)
        self$rOC <- private$addCriterion(self$rOC)
        mejoresUmbrales <- self$rOC %>% 
            group_by(criterio) %>%
            summarize(
                umbral = median(umbrales),
                error = median(pError)
            ) %>%
            arrange(criterio)
        return(mejoresUmbrales[1, c(2,3)])
    },

    calculateError = function(datos, umbral) {
        confusion <- private$calculateConfusion(datos, umbral)
        confusion <- private$addMissing(confusion)
        pError <- private$calculateErrorRate(confusion)
        return(pError)
    }
  ),

  private = list(
    classifyAnswer = function(renglon, umbral) {
        respuesta <- ifelse(renglon$prob > umbral, 1, 0)
        falsoOVerdadero <- ifelse(renglon$y_test == respuesta, 'V', 'F')
        clasificacion <- paste0(falsoOVerdadero, respuesta)
        return(clasificacion)
    },

    calculateConfusion = function(datos, umbral) {
        confusion <- datos %>% 
        mutate(clasificacion = private$classifyAnswer(., umbral)) %>% 
        group_by(clasificacion) %>%
        summarize(N = n())
        return(confusion)
    },
      
    addMissing = function(confusion) {
        clasificacion <- c('F0','F1','V0','V1')
        N <- c(0, 0, 0, 0)
        base <- data.frame(clasificacion, N)
        confusion <- confusion %>% merge(base, by = "clasificacion", all = T) %>% 
            mutate(N = N.x + N.y) %>% 
            mutate(N = ifelse(is.na(N), 0, N)) %>%
            select(c(1, 4))
        return(confusion)
    },
      
    calculateTPR = function(confusion) {
        tpr <- confusion[[4, 2]] / (confusion[[4, 2]] + confusion[[1, 2]])
        return(tpr)
    },
      
    calculateFPR = function(confusion) {
        fpr <- confusion[[2, 2]] / (confusion[[3, 2]] + confusion[[2, 2]])
        return(fpr)
    },
      
    calculateErrorRate = function(confusion) {
        error <- ((confusion[[2, 2]] + confusion[[1,2]]) / sum(confusion[, 2])) * 100
        return(error)
    },

    calculateROC = function(datos) {
        umbrales <- 1:100 * 0.01
        fPR <- c()
        tPR <- c()
        pError <- c()
        for (umbral in umbrales) {
            confusion <- private$calculateConfusion(datos, umbral)
            confusion <- private$addMissing(confusion)
            fPR <- append(fPR, private$calculateFPR(confusion))
            tPR <- append(tPR, private$calculateTPR(confusion))
            pError <- append(pError, private$calculateErrorRate(confusion))
        }                     
        ROC <- data.frame(umbrales, tPR, fPR, pError)
        return(ROC)
    },

    addCriterion = function(rOC) {
        rOC <- rOC %>% 
            mutate(criterio = sqrt((fPR)^2 + (1 - tPR)^2)) 
        return(rOC)
    }
  )
)