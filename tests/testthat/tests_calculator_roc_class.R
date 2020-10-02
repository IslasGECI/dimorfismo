library(data.table)
library(dimorfismo)
library(testthat)

calculator_roc <- roc$new()
threshold_fake <- 0.285
fake_data_to_test <- data.frame(
  y_tests = c(1, 0, 1, 1, 0, 1, 0, 1, 0, 1),
  prob = c(
    9.287569, 3.667945, 9.398461, 1.513707, 8.624482,
    9.996934, 1.176383, 9.548987, 2.338850, 6.769900
  )
)

test_that("El método best_threshold_error funciona", {
  expect_equal(calculator_roc$best_threshold_error(fake_data_to_test)$"threshold"[1], 0.505)
  expect_equal(calculator_roc$best_threshold_error(fake_data_to_test)$"error"[1], 40)
})

test_that("El método calculate_error funciona", {
  expect_equal(calculator_roc$calculate_error(fake_data_to_test, threshold_fake), 40)
})
