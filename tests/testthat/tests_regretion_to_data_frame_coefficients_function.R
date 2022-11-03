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

test_that("Coefficent is 0.619 for fit_null_model", {
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
  obtained <- line(0)
  expect_equal(expected, obtained)
  expected <- 8
  obtained <- line(1)
  expect_equal(expected, obtained)
  expected <- 13
  obtained <- line(2)
  expect_equal(expected, obtained)
  expected <- c(3, 8, 13)
  obtained <- line(c(0, 1, 2))
  expect_equal(expected, obtained)
})

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

test_that("Empty data frame", {
  expected <- data.frame(
    matrix(
      ncol = 3,
      nrow = 3
    )
  )
  obtained <- make_empty_dataframe(3, 3)
  expect_equal(expected, obtained)
})

test_that("Expected elements number ", {
  empty <- make_empty_dataframe(3, 3)
  expected <- 6
  obtained <- length(make_null_modeltable(empty))
  expect_equal(expected, obtained)
})

test_that("Column names ", {
  expected_name <- c(
    "(Intercept)", "beak_height", "beak_length", "skull_length", "skull_width",
    "tarsus", "close_brim_length", "open_brim_length", "wingspan"
  )
  empty <- make_empty_dataframe(3, length(expected_name))
  model_table <- make_null_modeltable(empty)
  model_table <- rename_model_table(model_table)
  obtained_name <- names(model_table$model_coefficients)
  expect_equal(obtained_name, expected_name)
})

test_that("Add sex to numerical data ", {
  data_path <- "../data/trainning_data.csv"
  trainning_data <- read_csv(data_path)
  obtained <- add_sex_to_data(trainning_data)
  obtained_num_columns <- ncol(obtained)
  expected_num_columns <- 16
  expect_equal(obtained_num_columns, expected_num_columns)
})

test_that("Remove NA rows ", {
  variables_model <- c(
    "beak_height", "beak_length", "skull_length", "skull_width",
    "tarsus", "close_brim_length", "open_brim_length", "wingspan"
  )
  data_path <- "../data/trainning_sex_data.csv"
  data_with_sex <- read_csv(data_path)
  data_set_for_model <- delete_NA_from_column(data_with_sex, variables_model)
  expected_num_NA <- 0
  obteined_num_NA <- sum(is.na(data_set_for_model$masa))
  expect_equal(obteined_num_NA, expected_num_NA)
  expected_row <- nrow(data_with_sex) - 1
  obtained_row <- nrow(data_set_for_model)
  expect_equal(obtained_row, expected_row)
})

test_that("get_normalize_data remove a row with NA and change from H and F to 0 and 1", {
  data_path_NA <- "../data/No_NA_trainning_data.csv"
  data_path_sex <- "../data/trainning_sex_data.csv"
  data_with_sex <- read_csv(data_path_sex)
  data_set_for_model <- read_csv(data_path_NA)
  normalized_data <- get_normalize_data(data_set_for_model, data_with_sex)
  expected_row <- nrow(data_with_sex) - 1
  obtained_row <- nrow(normalized_data)
  expect_equal(obtained_row, expected_row)
  expected_sex_type <- "integer"
  obtained_sex_type <- typeof(normalized_data$sexo)
  expect_equal(obtained_sex_type, expected_sex_type)
})
