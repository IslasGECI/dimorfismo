library(tidyverse)
library(dimorfismo)
library(testthat)

sintetic_data <- tibble(
  sexo = c(0.0009, 0.0024, 0.0067, 0.018, 0.047, 0.119, 0.269, 0.500, 0.731, 0.881, 0.953, 0.982, 0.993, 0.998, 0.999, 1, 1, 1, 1, 1),
  x = seq(-2, 1.8, 0.2)
)
sintetic_data2 <- sintetic_data %>% mutate(sexo = rbinom(20, 1, sintetic_data$sexo))
