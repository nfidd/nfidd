#' Discretise a Continuous Delay Distribution
#'
#' This function discretises a continuous delay distribution into a probability
#' mass function (PMF) over discrete days.
#'
#' @param rgen A function that generates random delays, e.g., `rgamma`,
#' `rlnorm`.
#' @param max The maximum delay.
#' @param n The number of replicates to simulate. Defaults to `1e+6`.
#' @param ... Additional parameters of the delay distribution.
#'
#' @return A vector of probabilities corresponding to discrete indices from
#'   `0` to `max`, representing the discretised delay distribution.
#'
#' @examples
#' censored_delay_pmf(rgen = rgamma, max = 14, shape = 5, rate = 1)
censored_delay_pmf <- function(rgen, max, n = 1e+6, ...) {
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
