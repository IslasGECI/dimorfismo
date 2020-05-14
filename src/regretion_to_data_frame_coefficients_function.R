#' Escribe el nombre abreviado a partir del nombre científico.
#'
#' Escribe el nombre abreviado definido como la inicial del orden y el nombre 
#' de la especie. Si el nombre científico llega hasta subespecie entonce 
#' también el nombre de la especia contribuye solo con la inicial y el nombre
#' de la subespecie con el nombre completo.
#'
#' @author Nepo Rojas <braulio.rojas@@islas.org.mx>
#'
#' @usage especiesConNombreCorto <- shortName(especiesSinNombreCorto)
#' # Agrega una nueva columna y deja todas las anteriore sin modificación de
#' \code{especiesSinNombreCorto} en nuevo dataframe \code{especiesConNombreCorto}.
#'
#' @param  especieSinNombreCorto(dataframe) es la información de las especies.
#'
#' @return  especiesConNombreCorto(dataframe) es la misma información de la 
#' variables de entrada \code{especieSinNombreCorto} pero con la nueva columna
#' nombreCorto. 
#'
#' @references
#'
#' @examples
#' datos <- c(1234, 2854, 378965, 4755, 54554, 67898)
#' estadisticaDescriptiva <- descStat(datos)
#' estadisticaDescriptiva
#' # $tamanoMuestra
#' # [1] 6
#' # $media
#' # [1] 85043.33
#' # $desviacionEstandar
#' # [1] 146859.7
#' # $errorEstandar
#' # [1] 59955.21
#' # $margenError
#' # [1] 154119.8
#' # $margenErrorPorcentual
#' # [1] 181.225
#' # $minimo
#' # [1] 1234
#' # $maximo
#' # [1] 378965
#' # $coeficienteVariacion
#' # [1] 1.72688
#' # $intervaloConfianza
#' # [1] -69076.44 239163.11
#'
#' @seealso
#'
#' @encoding utf-8
#' @export
#' 
regretion2DataFrameCoefficients <- function(Regresion) {
    ResumenRegresion <- summary.glm(Regresion)
    ResumenRegresion$coefficients <- round(ResumenRegresion$coefficients, 3)
    DataFrame <- as.data.frame(ResumenRegresion$coefficients)
    DataFrame <- cbind(rownames(DataFrame), DataFrame)
    colnames(DataFrame)[1] <- "Variables"
    return(DataFrame)
}