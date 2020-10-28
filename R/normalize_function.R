#' @export

normalize <- function(column) {
  normalize_return <- (column - min(column)) / (max(column) - min(column))
}
