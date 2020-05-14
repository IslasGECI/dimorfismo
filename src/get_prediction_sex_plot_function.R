library(ggplot2)
getPredictionSexPlot <- function(TablaDatos, prediccion) {
  graficaPrediccion <- ggplot(TablaDatos,aes(x = darvic, y = prediccion, color=sexo, shape = sexo)) +
  geom_point(size = 5) +
  scale_x_discrete(labels = TablaDatos$darvic) +
  labs(x = "ID Darvic", y = "Sexo") +
  # Se ponen las etiquetas del eje x en vertical para que se puedan leer
  theme(axis.text.x = element_text(angle = 90, size = 5, vjust = 0.5))
  return(graficaPrediccion)
}
