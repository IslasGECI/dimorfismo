library(data.table)
library(dimorfismo)
library(testthat)
library(tidyverse)

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

sintetic_data <- tibble(sexo = c(rep(TRUE, 13), rep(FALSE, 7)), a = seq(0.05, 1, 0.05))

test_that("Coefficent is 0.60 for fit_null_model", {
  modelo_ajustado <- fit_null_model(sintetic_data)
  obtanided_coefficient <- modelo_ajustado$coefficients
  names(obtanided_coefficient) <- c()
  expected_coefficient <- 0.619
  expect_equal(expected_coefficient, obtanided_coefficient, tolerance = 1e-3)
})

test_that("Coefficent is 552, -818 for fit_complete_model", {
  modelo_ajustado <- fit_complete_model(sintetic_data)
  obtanided_coefficient <- modelo_ajustado$coefficients
  names(obtanided_coefficient) <- c()
  expected_coefficient <- c(552, -818)
  expect_equal(expected_coefficient, obtanided_coefficient, tolerance = 1e-3)
})

test_that("Logistic regretion from scratch", {
  expected <- 3
  obtained <- ttt(0)
  expect_equal(expected, obtained)
  expected <- 8
  obtained <- ttt(1)
  expect_equal(expected, obtained)
  expected <- 13
  obtained <- ttt(2)
  expect_equal(expected, obtained)
  expected <- c(3, 8, 13)
  obtained <- ttt(c(0, 1, 2))
  expect_equal(expected, obtained)
})

sintetic_data <- tibble(sexo = c(0.0009, 0.0024, 0.0067, 0.018, 0.047, 0.119, 0.269, 0.500, 0.731, 0.881, 0.953, 0.982, 0.993, 0.998, 0.999, 1, 1, 1, 1, 1), x = seq(-2, 1.8, 0.2))
sintetic_data2 <- sintetic_data %>% mutate(sexo = rbinom(20, 1, sintetic_data$sexo))

test_that("Logistic function", {
  expected <- 0.953
  obtained <- logt(0)
  expect_equal(expected, obtained, tolerance = 1e-3)
  expected <- c(0.953, 0.999, 0.999)
  obtained <- logt(c(0, 1, 2))
  expect_equal(expected, obtained, tolerance = 1e-3)
  expected <- c(0.001, 0.953, 0.999)
  obtained <- logt(seq(-2, 2, 2))
  expect_equal(expected, obtained, tolerance = 1e-3)
  expected <- c(0.0009, 0.0024, 0.0067, 0.018, 0.047, 0.119, 0.269, 0.500, 0.731, 0.881, 0.953, 0.982, 0.993, 0.998, 0.999, 1, 1, 1, 1, 1)
  obtained <- logt(seq(-2, 1.8, 0.2))
  expect_equal(expected, obtained, tolerance = 1e-3)
})
