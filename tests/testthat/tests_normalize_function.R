library(dimorfismo)
library(testthat)

test_data <- c(
    100, 105, 200, 250, 300, 350
)

normalized_data <- c(0, 0.02, 0.4, 0.6, 0.8, 1)

test_that("La función normalize_function funciona: ", {
    expect_equal(normalized_data, normalize(test_data))
})
