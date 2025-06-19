#' Summarise lognormal distribution parameters
#'
#' Extract mean and standard deviation from lognormal distribution parameters
#' in a posterior or draws object.
#'
#' @param posterior_obj A posterior or draws object containing lognormal parameters
#' @param meanlog_var Name of the meanlog parameter variable (default: "meanlog")
#' @param sdlog_var Name of the sdlog parameter variable (default: "sdlog")
#'
#' @return A summary of the mean and standard deviation of the lognormal distribution
#'
#' @details
#' This function extracts lognormal parameters from a posterior object and
#' calculates the mean and standard deviation on the natural scale using:
#' - mean = exp(meanlog + 0.5 * sdlog^2)
#' - sd = exp(meanlog + 0.5 * sdlog^2) * sqrt(exp(sdlog^2) - 1)
#'
#' @importFrom dplyr mutate select
#' @importFrom rlang sym !!
#' @importFrom tidybayes spread_draws
#'
#' @autoglobal
#' @export
#'
#' @examples
#' \dontrun{
#' # After fitting a lognormal model with cmdstan
#' res |> summarise_lognormal()
#' 
#' # With custom parameter names
#' res |> summarise_lognormal(meanlog_var = "mu", sdlog_var = "sigma")
#' }
summarise_lognormal <- function(posterior_obj, 
                               meanlog_var = "meanlog", 
                               sdlog_var = "sdlog") {
  posterior_obj |>
    spread_draws(!!sym(meanlog_var), !!sym(sdlog_var)) |>
    mutate(
      mean = exp(!!sym(meanlog_var) + 0.5 * (!!sym(sdlog_var))^2),
      sd = exp(!!sym(meanlog_var) + 0.5 * (!!sym(sdlog_var))^2) * 
        sqrt(exp((!!sym(sdlog_var))^2) - 1)
    ) |>
    select(mean, sd) |>
    summary()
}
