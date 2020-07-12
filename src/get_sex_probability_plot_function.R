library(ggplot2)
getPredictionSexPlot <- function(TablaDatos, prediccion) {
  graficaPrediccion <- ggplot(TablaDatos,aes(x=Darvic,y=prediccion,color=Sexo,shape=Sexo)) +
  geom_point(size=5) +
  scale_x_discrete(labels = TablaDatos$Darvic) +
  labs(x = "ID Darvic", y = "Sexo") +
  # Se ponen las etiquetas del eje x en vertical para que se puedan leer
  theme(axis.text.x = element_text(angle = 90, size=5, vjust=0.5))
  return(graficaPrediccion)
}






