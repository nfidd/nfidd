#' Summarise lognormal distribution parameters
#'
#' Extract mean and standard deviation from lognormal distribution parameters
#' in a posterior or draws object.
#'
#' @param posterior_obj A posterior or draws object containing lognormal
#'   parameters
#'
#' @return A summary of the mean and standard deviation of the lognormal
#'   distribution
#'
#' @details
#' This function extracts lognormal parameters from a posterior object (expcting
#'   them to be called `meanlog` and `sdlog`and calculates the mean and standard
#'   deviation on the natural scale using:
#' \itemize{
#' \item \code{mean = exp(meanlog + 0.5 * sdlog^2)}
#' \item \code{sd = exp(meanlog + 0.5 * sdlog^2) * sqrt(exp(sdlog^2) - 1)}
#' }
#'
#' @importFrom dplyr mutate select
#' @importFrom tidybayes spread_draws
#'
#' @autoglobal
#' @export
#'
#' @examples
#' \dontrun{
#' # After fitting a lognormal model with cmdstan
#' res |> summarise_lognormal()
#' }
summarise_lognormal <- function(posterior_obj) {
  posterior_obj |>
    spread_draws(meanlog, sdlog) |>
    mutate(
      mean = exp(meanlog + 0.5 * (sdlog)^2),
      sd = exp(meanlog + 0.5 * (sdlog)^2) * sqrt(exp((sdlog)^2) - 1)
    ) |>
    select(mean, sd) |>
    summary()
}
