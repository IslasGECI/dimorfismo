regretion2DataFrameCoefficients <- function(regression) {
    regression_summary <- summary.glm(regression)
    regression_summary$coefficients <- round(regression_summary$coefficients, 3)
    data_frame <- as.data.frame(regression_summary$coefficients)
    data_frame <- cbind(rownames(data_frame), data_frame)
    colnames(data_frame)[1] <- "Variables"
    return(data_frame)
}