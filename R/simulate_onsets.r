#' Generate a probability mass function for the generation time
#'
#' @param max Maximum delay to consider
#' @param shape Shape parameter for the gamma distribution
#' @param rate Rate parameter for the gamma distribution
#'
#' @return A vector of probabilities representing the generation time PMF
#'
#' @export
#'
#' @importFrom stats rgamma
make_gen_time_pmf <- function(max = 14, shape = 4, rate = 1) {
  pmf <- censored_delay_pmf(rgamma, max = max, shape = shape, rate = rate)
  pmf <- pmf[-1] # remove first element
  pmf <- pmf / sum(pmf) # renormalise
  return(pmf)
}

#' Generate a probability mass function for the incubation period
#'
#' @param max Maximum delay to consider
#' @param shape Shape parameter for the gamma distribution
#' @param rate Rate parameter for the gamma distribution
#'
#' @return A vector of probabilities representing the incubation period PMF
#'
#' @export
#'
#' @importFrom stats rgamma
make_ip_pmf <- function(max = 14, shape = 5, rate = 1) {
  censored_delay_pmf(rgamma, max = max, shape = shape, rate = rate)
}

#' Simulate symptom onsets from daily infection counts
#'
#' @param inf_ts A data frame containing columns infection_day and infections,
#'   as returned by `make_daily_infections()`.
#'
#' @param gen_time_pmf A vector of probabilities representing the generation
#'   time PMF, as returned by `make_gen_time_pmf()`.
#'
#' @param ip_pmf A vector of probabilities representing the incubation period
#'   PMF, as returned by `make_ip_pmf()`.
#'
#' @return A data frame with columns day, onsets, and infections containing
#'   the daily count of symptom onsets and infections
#'
#' @importFrom stats rgamma rpois
#' @importFrom dplyr tibble left_join select
#' @importFrom tidyr replace_na
#'
#' @autoglobal
#' @export
#'
#' @examples
#' gt_pmf <- make_gen_time_pmf()
#' ip_pmf <- make_ip_pmf()
#' simulate_onsets(make_daily_infections(infection_times), gt_pmf, ip_pmf)
simulate_onsets <- function(inf_ts, gen_time_pmf = make_gen_time_pmf(),
                            ip_pmf = make_ip_pmf()) {
  onsets <- convolve_with_delay(inf_ts$infections, ip_pmf)
  onsets <- rpois(n = length(onsets), lambda = onsets)
  onset_df <- tibble(day = seq_along(onsets), onsets = onsets) |>
    left_join(
      inf_ts |> select(day = infection_day, infections),
      by = "day"
    ) |>
    replace_na(list(infections = 0))

  return(onset_df)
}
