library(data.table)
library(dimorfismo)
library(testthat)

test_data <- data.frame(
  temp = c(
    11.9, 14.2, 15.2, 16.4, 17.2, 18.1,
    18.5, 19.4, 22.1, 22.6, 23.4, 25.1
  ),
  units = c(
    185L, 215L, 332L, 325L, 408L, 421L,
    406L, 412L, 522L, 445L, 544L, 614L
  )
)

pois_mod <- glm(units ~ temp,
  data = test_data,
  family = poisson(link = "log")
)

regresion_step <- step(pois_mod)
coeficientes_step <- regretion_to_data_frame(regresion_step)

test_that("La función regresa un data.frame", {
  correct_class <- "data.frame"
  obtained_class <- class(coeficientes_step)
  expect_equal(obtained_class, correct_class)
})
