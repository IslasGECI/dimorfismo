source("../../src/functions/dimorfismo.R")
Mi_Primera_Clase <- My_First_Class$new() 
test_that("Que tengan los requerimientos para POO",
    {
        expect_true(is_library("tidyverse"))
        expect_true(is_element("myFirstClass", class(Mi_Primera_Clase)))
    }
)
