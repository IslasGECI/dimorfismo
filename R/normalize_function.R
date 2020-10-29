#' @export

normalize <- function(column) {
  (column - min(column)) / (max(column) - min(column))
}
