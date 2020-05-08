write_a_word <- function(parameter) {
    return(parameter)
}

resolve_riddle <- function(parameter_1, parameter_2) {
    answer <- (parameter_1 * parameter_2) + parameter_1
    return(answer)
}

is_library <- function(library) {
    installed <- installed.packages()
    packages <- installed[ , 1]
    answer <- is.element(library, packages)
    return(answer)
}
