correct_minimum_error <- 7.40740740740740655212448473

correct_step_coefficients <- data.frame(
    A = c("(Intercept)", "longitud pico", "altura pico", "longitud craneo", "tarso"),
    B = c(-12.870, 6.648, 6.700, 6.956, 4.086),
    C = c(2.792, 3.083, 2.616, 3.687, 2.369),
    D = c(-4.610, 2.156, 2.561, 1.887, 1.725),
    E = c(0, 0.031, 0.010, 0.059, 0.085)
)

colnames (correct_step_coefficients) <- c("Variables", "Estimate", "Std. Error", "z value", "Pr(>|z|)")
rownames (correct_step_coefficients) <- c(
    "(Intercept)", "longitud pico", "altura pico", "longitud craneo", "tarso"
)
