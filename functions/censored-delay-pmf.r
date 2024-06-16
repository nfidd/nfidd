## function that takes two inputs to discretise a continuous delay distribution
##
## function arguments:
## rgen: a function that generates random delays, e.g. rgamma, rlognormal
## n: the number of replicates to simulate
## max: the maximum delay
## ...: parameters of the delay distribution
## the function returns a vector of probabilities, corresponding to discrete
## indices 0, 1, 2 of the discretised delay distribution
##
## example: censored_delay_pmf(rgamma, max = 14, shape = 5, rate = 1)
censored_delay_pmf <- function(rgen, n = 1e+6, max, ...) {
  ## first, simulate exact time of first event (given by day), uniformly
  ## between 0 and 1
  first <- runif(n, min = 0, max = 1)
  ## now,  simulate the exact time of the second event
  second <- first + rgen(n, ...)
  ## round down to get the delay in days
  delay <- floor(second)
  ## get vector of counts
  counts <- table(factor(delay, levels = seq(0, max)))
  ## normalise to get pmf
  pmf <- counts / sum(counts)
  ## return
  return(pmf)
}
