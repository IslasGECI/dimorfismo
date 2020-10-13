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
outcome_threshold_error <- calculator_roc$best_threshold_error(fake_data_to_test)
outcome_error <- outcome_threshold_error$"error"[1]
outcome_threshols <- outcome_threshold_error$"threshold"[1]

test_that("El método best_threshold_error funciona correctamente: ", {
  expected_error <- 40
  expected_threshold <- 0.505
  expect_equal(outcome_error, expected_error)
  expect_equal(outcome_threshols, expected_threshold)
})
