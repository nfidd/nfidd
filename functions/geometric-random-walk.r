## function that takes three inputs to perform a geometric random walk
##
## function arguments:
## init: the initial value
## noise: a vector of steps (on the standard normal scale)
## std: the step size of the random walk
##
## example: geometric_random_walk(init = 1, noise = rnorm(100), std = 0.1)
geometric_random_walk <- function(init, noise, std) {
  ## number of values: initial and each of the steps
  n <- length(noise) + 1
  ## declare vector
  x <- numeric(n)
  ## initial value
  x[1] <- init
  ## random walk
  for (i in 2:n) {
    x[i] <- x[i - 1] + noise[i - 1] * std
  }
  return(exp(x))
}
