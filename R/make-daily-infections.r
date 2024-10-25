#' Convert infection times to a daily time series
#'
#' @param infection_times A data frame containing a column of infection times
#'
#' @return A data frame with columns infection_day and infections, containing
#'   the daily count of infections
#'
#' @importFrom dplyr transmute count full_join join_by
#' @importFrom tidyr expand replace_na
#'
#' @examples
#' make_daily_infections(infection_times)
make_daily_infections <- function(infection_times) {
  ## Censor infection times to days
  df <- infection_times |>
    transmute(infection_day = floor(infection_time))

  ## Summarise infections as a time series by day
  inf_ts <- df |>
    count(infection_day, name = "infections")

  ## fill data frame with zeroes for days without infection
  all_days <- expand(
    df, infection_day = seq(min(infection_day), max(infection_day))
  )
  inf_ts <- all_days |>
    full_join(inf_ts, by = join_by(infection_day)) |>
    replace_na(list(infections = 0))

  return(inf_ts)
}
