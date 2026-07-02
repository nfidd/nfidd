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
# #' @references
# nolint start: object_name_linter
renewal <- function(I0, R, gen_time) {
  max_gen_time <- length(gen_time) ## gen_time starts at day 1
  I <- c(I0, rep(0, length(R))) ## infections, with I0 prepended at index 1
  for (i in seq_along(R)) {
    ## window of past infections contributing to the current time point
    first_index <- max(1, i - max_gen_time + 1)
    len <- i - first_index + 1
    segment <- I[seq(first_index, i)]
    ## reverse the (possibly truncated) generation time to align with the segment
    gen_pmf <- rev(gen_time[seq_len(len)])
    ## renewal equation: convolve past infections with the generation time, scale by R
    I[i + 1] <- sum(segment * gen_pmf) * R[i]
  }
  I[-1] ## drop the prepended I0
}
# nolint end
