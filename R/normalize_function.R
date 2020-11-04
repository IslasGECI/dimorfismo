#' @export
normalize <- function(column, minimum = min(column), maximum = max(column)) {
  normalize_return <- (column - minimum) / (maximum - minimum)
  return(normalize_return)
}