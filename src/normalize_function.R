normalize <- function(column) {
    normalize_return <- (column - min(column)) / (max(column) - min(column))
    return(normalize_return)
}
