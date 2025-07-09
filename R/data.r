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

#' Data on forecasted locations from the US COVID-19 Forecast Hub
#'
#' A dataset containing 53 rows with metadata about each US state.
#' The dataset was downloaded from
#' https://raw.githubusercontent.com/CDCgov/covid19-forecast-hub/refs/heads/main/auxiliary-data/locations.csv
#' @format A [tibble::tibble()] with a 4 columns and 53 rows
#' \describe{
#'   \item{abbreviation}{two-letter abbreviation for a jurisdiction}
#'   \item{location}{a two-letter FIPS code for identifying the jurisdiction}
#'   \item{location_name}{name of the jurisdiction}
#'   \item{population}{population of the jurisdiction as of some unknown time}
#' }
"covid_locations"

#' Time-series data on COVID-19 in the US
#'
#' A dataset containing versions of time-series data on COVID-19 in the US,
#' including data on weekly counts of hospital admissions due to COVID-19.
#' The first week of data for which observations are available ended on
#' 2022-10-01 and the last week ended on 2025-06-28. This dataset was downloaded
#' on 2025-07-09, with versions as early as 2024-11-20 (when the hub started
#' recording this dataset).
#'
#' @format A [tibble::tibble()] with a 6 columns and 52,778 rows.
#' \describe{
#'   \item{date}{date of the Saturday ending an epidemic week for which the
#'   count was made}
#'   \item{state}{two-letter abbreviation for a jurisdiction}
#'   \item{observation}{the count of the observation, e.g. number of hospital
#'   admissions in that week and location}
#'   \item{location}{a two-letter FIPS code for identifying the jurisdiction}
#'   \item{as_of}{date corresponding to the date (typically a Wednesday) the
#'   data were archived}
#'   \item{target}{the name of the prediction target: "wk inc covid hosp"}
#' }
"covid_time_series"


#' Forecast data for COVID-19 hospitalizations in the US
#'
#' A dataset containing forecasts of hospital admission counts in the US from
#' November 2024 through June 2025.
#'
#' @format A [tibble::tibble()] with a 9 columns and 2,179,756 rows.
#' \describe{
#'   \item{reference_date}{the date of the Saturday following the Wednesday
#'   forecast submission date each week}
#'   \item{target}{"wk inc covid hosp", the name of the forecast target,
#'   corresponding to weekly incident covid hospitalizations}
#'   \item{horizon}{an integer between -1 and 3, corresponding to the
#'   prediction horizon}
#'   \item{location}{a two-letter FIPS code for identifying the jurisdiction}
#'   \item{target_end_date}{date corresponding to the Saturday ending the
#'   epiweek being forecasted}
#'   \item{output_type}{string denoting the forecast format, here, all "quantile"}
#'   \item{output_type_id}{number between 0 and 1 indicating the quantile level
#'   corresponding to the prediction}
#'   \item{value}{the numeric value of the prediction at the specified quantile
#'   level}
#'   \item{model_id}{the unique character string identifying the model that
#'   made the prediction}
#' }
"covid_forecasts"
