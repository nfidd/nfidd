## function that takes four inputs to perform a geometric differenced random walk
##
## function arguments:
## init: the initial value
## noise: a vector of steps (on the standard normal scale)
## std: the step size of the random walk
## damp: a damping parameter
##
## example: geometric_diff_ar(init = 1, noise = rnorm(100), phi = 0.1,  std = 0.1)
geometric_diff_ar <- function(init, noise, std, damp) {
  ## number of values: initial and each of the steps
  n <- length(noise) + 1
  ## declare vector
  x <- numeric(n)
  ## initial value
  x[1] <- init
  ## second value (no difference yet available for use)
  x[2] <- x[1] + noise[1] * std
  ## random walk
  for (i in 3:n) {
    x[i] <- x[i - 1] + damp * (x[i - 1] - x[i - 2]) + noise[i - 1] * std
  }
  return(exp(x))
}
