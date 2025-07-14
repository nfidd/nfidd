#' Simulate symptom onset and hospitalization times from infection times
#'
#' @param infection_times A data frame containing a column of infection times
#' @param onset_fun Function for onset delay distribution (default rgamma)
#' @param onset_params List of parameters for onset distribution
#' @param hosp_fun Function for hospitalization delay distribution (default rlnorm)
#' @param hosp_params List of parameters for hospitalization distribution
#' @param hosp_prob Probability of hospitalization (default 0.3)
#'
#' @return A data frame with columns for infection time, onset time, and
#'   hospitalization time (with (1-hosp_prob) of hospitalizations set to NA)
#'
#' @importFrom dplyr mutate n if_else
#' @importFrom stats rgamma rlnorm rbinom
#'
#' @autoglobal
#' @export
#'
#' @examples
#' # Default parameters
#' delayed_infections <- add_delays(infection_times)
#' head(delayed_infections)
#' 
#' # Change delay parameters
#' delayed_infections_long <- add_delays(
#'   infection_times, 
#'   hosp_params = list(n = nrow(infection_times), meanlog = 2.0, sdlog = 0.5)
#' )
#' 
#' # Use different distributions
#' delayed_infections_gamma <- add_delays(
#'   infection_times,
#'   hosp_fun = rgamma,
#'   hosp_params = list(n = nrow(infection_times), shape = 2, rate = 0.5)
#' )
add_delays <- function(infection_times, 
                      onset_fun = rgamma,
                      onset_params = list(shape = 5, rate = 1),
                      hosp_fun = rlnorm, 
                      hosp_params = list(meanlog = 1.75, sdlog = 0.5),
                      hosp_prob = 0.3) {
  
  n_obs <- nrow(infection_times)
  
  # Generate delays using do.call
  onset_delays <- do.call(onset_fun, c(list(n = n_obs), onset_params))
  hosp_delays <- do.call(hosp_fun, c(list(n = n_obs), hosp_params))
  
  # Add delays to infection times
  df <- infection_times |>
    mutate(
      onset_time = infection_time + onset_delays,
      hosp_time = onset_time + hosp_delays
    )

  # Set random proportion of hospitalization dates to NA
  df |>
    mutate(
      hosp_time = if_else(
        rbinom(n = n(), size = 1, prob = hosp_prob) == 1,
        hosp_time,
        NA_real_
      )
    )
}
