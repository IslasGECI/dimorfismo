#' @export
regretion_to_data_frame <- function(regression) {
  regression_summary <- summary.glm(regression)
  regression_summary$coefficients <- round(regression_summary$coefficients, 3)
  data_frame <- as.data.frame(regression_summary$coefficients)
  data_frame <- cbind(rownames(data_frame), data_frame)
  colnames(data_frame)[1] <- "Variables"
  return(data_frame)
}

#' @export
fit_null_model <- function(normalized_data) {
  null_regression <- glm(
    formula = sexo ~ 1,
    data = normalized_data,
    family = "binomial"
  )
  return(null_regression)
}

#' @export
fit_complete_model <- function(normalized_data) {
  all_regression <- glm(
    formula = sexo ~ .,
    data = normalized_data,
    family = binomial(link = "logit")
  )
  return(all_regression)
}

#' @export
fit_stepwise <- function(null, all) {
  step_regression <- step(null,
    scope = list(
      lower = null,
      upper = all
    ),
    direction = "both",
    trace = 0
  )
  return(step_regression)
}

#' @export
line <- function(x) {
  return((3) + (5) * x)
}

logt <- function(x) {
  p <- 1 / (1 + exp(-line(x)))
}
