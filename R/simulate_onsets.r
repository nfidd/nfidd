#' Simulate symptom onsets from daily infection counts
#'
#' @param inf_ts A data frame containing columns infection_day and infections,
#'   as returned by make_daily_infections()
#'
#' @return A data frame with columns day, onsets, and infections containing
#'   the daily count of symptom onsets and infections
#'
#' @importFrom stats rgamma rpois
#' @importFrom dplyr tibble left_join select
#' @importFrom tidyr replace_na
#'
#' @examples
#' simulate_onsets(make_daily_infections(infection_times))
simulate_onsets <- function(inf_ts) {
  gen_time_pmf <- censored_delay_pmf(rgamma, max = 14, shape = 4, rate = 1)
  gen_time_pmf <- gen_time_pmf[-1] ## remove first element
  gen_time_pmf <- gen_time_pmf / sum(gen_time_pmf) ## renormalise

  ip_pmf <- censored_delay_pmf(rgamma, max = 14, shape = 5, rate = 1)
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
