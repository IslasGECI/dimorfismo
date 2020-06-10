regretion2DataFrameCoefficients <- function(Regresion) {
    ResumenRegresion <- summary.glm(Regresion)
    ResumenRegresion$coefficients <- round(ResumenRegresion$coefficients, 3)
    DataFrame <- as.data.frame(ResumenRegresion$coefficients)
    DataFrame <- cbind(rownames(DataFrame), DataFrame)
    colnames(DataFrame)[1] <- "Variables"
    return(DataFrame)
}