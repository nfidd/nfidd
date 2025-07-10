#' Infection times
#'
#' A dataset containing random infection times from a branching process model,
#' generated using the code in data-raw/epicurve.r
#' @format A data frame with a single column
#' \describe{
#'   \item{infection_time}{the times at which individuals were infected (and
#'   became infectious)}
#' }
"infection_times"

#' Forecasts from a mechanistic model
#'
#' A dataset containing forecasts from a mechanistic model, generated using the
#' code in data-raw/generate-example-forecasts.r
#' @format A [tibble::tibble()] with a 7 columns
#' \describe{
#'   \item{day}{the day for which the forecast was made}
#'   \item{.draw}{an ID of the posterior predictive sample}
#'   \item{.variable}{name of the variable}
#'   \item{.value}{predicted value}
#'   \item{.horizon}{the forecast horizon in days}
#'   \item{origin_day}{the day on which the forecast was made (using data up to
#'   this day)}
#'   \item{model}{the name of the model}
#' }
"mech_forecasts"

#' Forecasts from a semi-mechanistic model
#'
#' A dataset containing forecasts from a semi-mechanistic model (using a
#' geometric random walk prior on the reproduction number), generated using the
#' code in data-raw/generate-example-forecasts.r
#' @format A [tibble::tibble()] with a 7 columns
#' \describe{
#'   \item{day}{the day for which the forecast was made}
#'   \item{.draw}{an ID of the posterior predictive sample}
#'   \item{.variable}{name of the variable}
#'   \item{.value}{predicted value}
#'   \item{.horizon}{the forecast horizon in days}
#'   \item{origin_day}{the day on which the forecast was made (using data up to
#'   this day)}
#'   \item{model}{the name of the model}
#' }
"rw_forecasts"

#' Forecasts from a semi-mechanistic model with additional statistical
#' complexity
#'
#' A dataset containing forecasts from a semi-mechanistic model (using an
#' autoregressive prior for reproduction number), generated using the code in
#' data-raw/generate-example-forecasts.r
#' @format A [tibble::tibble()] with a 7 columns
#' \describe{
#'   \item{day}{the day for which the forecast was made}
#'   \item{.draw}{an ID of the posterior predictive sample}
#'   \item{.variable}{name of the variable}
#'   \item{.value}{predicted value}
#'   \item{.horizon}{the forecast horizon in days}
#'   \item{origin_day}{the day on which the forecast was made (using data up to
#'   this day)}
#'   \item{model}{the name of the model}
#' }
"stat_forecasts"

#' Flusight ILI data for the USA starting with the 2003/2004 season through the
#' of the 2017/2018 season.
#'
#' A dataset containing Flusight WILI (weighted Influenza-like Illness) data
#' starting with the 2003/2004 season through the 2017/2018 season. Contains the
#' WILI signal that is published by the CDC  which measures the percentage of
#' all outpatient doctor's office visits due to ILI in a given epidemiological
#' week.
#'
#' @format A [tibble::tibble()] with a 3 columns and 780 rows
#' \describe{
#'   \item{region}{the region for which `wili` is represented, all "nat" for
#'   national here.}
#'   \item{epiweek}{The beginning of the (MMWR) epiweek, which starts on a
#'   Sunday and ends on a Saturday}
#'   \item{wili}{the weighted ILI (Influenza-like Illness) variable}
#' }
"flu_data"
