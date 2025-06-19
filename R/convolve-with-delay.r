#' Convolve a Time Series with a Delay Distribution
#'
#' This function convolves a time series with a delay distribution given as a
#' probability mass function (PMF).
#'
#' @param ts A vector of the time series to convolve.
#' @param delay_pmf The probability mass function of the delay, given as a
#'  vector of probabilities, corresponding to discrete indices 0, 1, 2 of the
#'  discretised delay distribution.
#'
#' @return A vector of the convolved time series.
#'
#' @export
#'
#' @examples
#' convolve_with_delay(ts = c(10, 14, 10, 10), delay_pmf = c(0.1, 0.6, 0.3))
convolve_with_delay <- function(ts, delay_pmf) {
  max_delay <- length(delay_pmf) - 1 ## subtract one because zero-indexed
  convolved <- numeric(length(ts))

  for (i in seq_along(ts)) {
    ## get vector of infections over the possible window of the delay period
    first_index <- max(1, i - max_delay)
    ts_segment <- ts[seq(first_index, i)]
    ## take reverse of pmf and cut if needed
    pmf <- rev(delay_pmf)[seq_len(i - first_index + 1)]
    ## convolve with delay distribution
    ret <- sum(ts_segment * pmf)
    convolved[i] <- ret
  }

  convolved
}
