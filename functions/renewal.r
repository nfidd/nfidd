## function that takes three inputs to simulate using the renewal equation
## I0: the initial number of infections
## R: the reproduction number, given as a vector with one entry per time point
## gen_time: the generation time distribution, given as a vector with one entry
## per day after infection (the first element corresponding to one day after
## infection)
## example: renewal(5, c(rep(3, 4), rep(0.5, 5)), c(0.1, 0.2, 0.3, 0.2, 0.1))
renewal <- function(I0, R, gen_time) {
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
    gen_pmf <- rev(gen_time)[seq_len(t - first_index + 1)]
    ## convolve infections with generation time
    I[t + 1] <- sum(I_segment * gen_pmf) * R[t]
  }
  return(I[-1]) ## remove I0 from time series
}
