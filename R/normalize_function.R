#' @export
normalize <- function(column, minimum = min(column), maximum = max(column)) {
  (column - minimum) / (maximum - minimum)
}
