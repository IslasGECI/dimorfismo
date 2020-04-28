source("../../src/functions/dimorfismo.R")
test_that("La función regresa la palabra que metimos de argumento",
    {
        expect_equal(resolve_riddle(1, 4), 5)
        expect_equal(resolve_riddle(2, 5), 12)
    }
)