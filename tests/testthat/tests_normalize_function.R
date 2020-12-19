library(dimorfismo)
library(testthat)

expected_result <- c(0, 0.02, 0.4, 0.6, 0.8, 1)
test_data <- c(100, 105, 200, 250, 300, 350)

describe("La función normalize_function funciona correctamente: ", {
    it("Caso 1: ", {
        data_to_test <- normalize(test_data)
        expect_equal(expected_result, data_to_test)
    })
    it("Caso 2: Incluyendo variables de entrada max y min", {
        max_test_data <- max(test_data)
        min_test_data <- min(test_data)
        limited_data_to_test <- normalize(test_data, min_test_data, max_test_data)
        expect_equal(expected_result, limited_data_to_test)
    })
})
