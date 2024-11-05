#' Infection times
#'
#' A dataset containing random infection times from a branching process model,
#' generated using the code in data-raw/epicurve.r
#' @format A data frame with a single column
#' \describe{
#'   \item{infection_time}{the times at which individuals were infected (and became infectious)}
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
#'   \item{target_day}{the day on which the forecast was made (using data up to this day)}
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
#'   \item{target_day}{the day on which the forecast was made (using data up to this day)}
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
#'   \item{target_day}{the day on which the forecast was made (using data up to this day)}
#'   \item{model}{the name of the model}
#' }
"stat_forecasts"
