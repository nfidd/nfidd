#' Simulate Infections using the Renewal Equation
#'
#' This function simulates infections using the renewal equation.
#'
#' @param I0 The initial number of infections.
#' @param R The reproduction number, given as a vector with one entry per time
#'   point.
#' @param gen_time The generation time distribution, given as a vector with one
#'   entry per day after infection (the first element corresponding to one day
#'   after infection).
#'
#' @return A vector of simulated infections over time.
#'
#' @export
#'
#' @examples
#' renewal(
#'   I0 = 5,
#'   R = c(rep(3, 4), rep(0.5, 5)),
#'   gen_time = c(0.1, 0.2, 0.3, 0.2, 0.1)
#' )
renewal <- function(I0, R, gen_time) {
  ## set the maximum generation time
  max_gen_time <- length(gen_time)
  ## number of time points
  times <- length(R)
  I <- c(I0, rep(0, times)) ## set up vector holding number of infected
  ## iterate over time points
  for (t in 1:times) {
    ## calculate convolution
    first_index <- max(1, t - max_gen_time + 1)
    I_segment <- I[seq(first_index, t)]
    ## iterate over generation times
    ## take reverse of pmf and reverse if needed
    gen_pmf <- rev(gen_time[seq_len(t - first_index + 1)])
    ## convolve infections with generation time
    I[t + 1] <- sum(I_segment * gen_pmf) * R[t]
  }
  return(I[-1]) ## remove I0 from time series
}
