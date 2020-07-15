library(R6)
library(tidyverse)

roc <- R6Class("roc",
  public = list(
    roc_data = NULL,
    initialize = function() {
    },

    best_threshold_error = function(data) {
      self$roc_data <- private$roc_calculate(data)
      self$roc_data <- private$add_criterion(self$roc_data)
      best_thresholds <- self$roc_data %>%
        group_by(criterion) %>%
        summarize(
          threshold = median(thresholds),
          error = median(p_error)
        ) %>%
        arrange(criterion)
      return(best_thresholds[1, c(2, 3)])
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
      true_or_false <- ifelse(row$y_test == answer, "V", "F")
      clasification <- paste0(true_or_false, answer)
      return(clasification)
    },

    calculate_confusion = function(data, threshold) {
      confusion <- data %>%
        mutate(clasification = private$classify_answer(., threshold)) %>%
        group_by(clasification) %>%
        summarize(n_missing = n())
      return(confusion)
    },

    add_missing = function(confusion) {
      clasification <- c("F0", "F1", "V0", "V1")
      n_missing <- c(0, 0, 0, 0)
      base <- data.frame(clasification, n_missing)
      confusion <- confusion %>%
        merge(base, by = "clasification", all = T) %>%
        mutate(n_missing = n_missing.x + n_missing.y) %>%
        mutate(n_missing = ifelse(is.na(n_missing), 0, n_missing)) %>%
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
      error <- ((confusion[[2, 2]] + confusion[[1, 2]]) / sum(confusion[, 2])) * 100
      return(error)
    },

    roc_calculate = function(data) {
      thresholds <- 1:100 * 0.01
      fpr_data <- c()
      tpr_data <- c()
      p_error <- c()
      for (threshold in thresholds) {
        confusion <- private$calculate_confusion(data, threshold)
        confusion <- private$add_missing(confusion)
        fpr_data <- append(fpr_data, private$calculate_FRP(confusion))
        tpr_data <- append(tpr_data, private$calculate_TPR(confusion))
        p_error <- append(p_error, private$calculate_error_rate(confusion))
      }
      roc <- data.frame(thresholds, tpr_data, fpr_data, p_error)
      return(roc)
    },

    add_criterion = function(roc_data) {
      roc_data <- roc_data %>%
        mutate(criterion = sqrt((fpr_data)^2 + (1 - tpr_data)^2))
      return(roc_data)
    }
  )
)
