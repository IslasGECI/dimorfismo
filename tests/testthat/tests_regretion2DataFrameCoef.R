library(data.table) 

#source("src/dimorphism_model_class.R")
#source("src/calculator_ROC_class.R")
source("src/regretion_to_data_frame_coefficients_function.R")

icecream <- data.frame(
  temp=c(11.9, 14.2, 15.2, 16.4, 17.2, 18.1, 
         18.5, 19.4, 22.1, 22.6, 23.4, 25.1),
  units=c(185L, 215L, 332L, 325L, 408L, 421L, 
          406L, 412L, 522L, 445L, 544L, 614L)
)
pois.mod <- glm(units ~ temp, data=icecream, 
              family=poisson(link="log"))

RegresionStep <- step(pois.mod)
CoeficientesStep <- regretion2DataFrameCoefficients(RegresionStep)