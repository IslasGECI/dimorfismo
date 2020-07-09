library(R6)
library(tidyverse)

ROC <- R6Class("ROC",
  public = list(
    rOC = NULL,
    initialize = function() {
    },

    best_threshold_error = function(data) {
        self$rOC <- private$roc_calculate(data)
        self$rOC <- private$add_criterion(self$rOC)
        best_thresholds <- self$rOC %>% 
            group_by(criterion) %>%
            summarize(
                threshold = median(thresholds),
                error = median(p_error)
            ) %>%
            arrange(criterion)
        return(best_thresholds[1, c(2,3)])
    },

    calculate_error = function(data, threshold) {
        confusion <- private$calculate_confusion(data, threshold)
        confusion <- private$add_missing(confusion)
        p_error <- private$calculate_error_rate(confusion)
        return(p_error)
    }
  ),

  private = list(
    classify_answer = function(row, threshold) {
        answer <- ifelse(row$prob > threshold, 1, 0)
        true_or_false <- ifelse(row$y_test == answer, 'V', 'F')
        clasification <- paste0(true_or_false, answer)
        return(clasification)
    },

    calculate_confusion = function(data, threshold) {
        confusion <- data %>% 
        mutate(clasification = private$classify_answer(., threshold)) %>% 
        group_by(clasification) %>%
        summarize(N = n())
        return(confusion)
    },
      
    add_missing = function(confusion) {
        clasification <- c('F0','F1','V0','V1')
        N <- c(0, 0, 0, 0)
        base <- data.frame(clasification, N)
        confusion <- confusion %>% 
        merge(base, by = "clasification", all = T) %>% 
        mutate(N = N.x + N.y) %>% 
        mutate(N = ifelse(is.na(N), 0, N)) %>%
        select(c(1, 4))
        return(confusion)
    },
      
    calculate_TPR = function(confusion) {
        tpr <- confusion[[4, 2]] / (confusion[[4, 2]] + confusion[[1, 2]])
        return(tpr)
    },
      
    calculate_FRP = function(confusion) {
        fpr <- confusion[[2, 2]] / (confusion[[3, 2]] + confusion[[2, 2]])
        return(fpr)
    },
      
    calculate_error_rate = function(confusion) {
        error <- ((confusion[[2, 2]] + confusion[[1,2]]) / sum(confusion[, 2])) * 100
        return(error)
    },

    roc_calculate = function(data) {
        thresholds <- 1:100 * 0.01
        fPR <- c()
        tPR <- c()
        p_error <- c()
        for (threshold in thresholds) {
            confusion <- private$calculate_confusion(data, threshold)
            confusion <- private$add_missing(confusion)
            fPR <- append(fPR, private$calculate_FRP(confusion))
            tPR <- append(tPR, private$calculate_TPR(confusion))
            p_error <- append(p_error, private$calculate_error_rate(confusion))
        }
        ROC <- data.frame(thresholds, tPR, fPR, p_error)
        return(ROC)
    },

    add_criterion = function(rOC) {
        rOC <- rOC %>% 
            mutate(criterion = sqrt((fPR)^2 + (1 - tPR)^2))
        return(rOC)
    }
  )
)