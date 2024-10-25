#' Simulate symptom onset and hospitalization times from infection times
#'
#' @param infection_times A data frame containing a column of infection times
#'
#' @return A data frame with columns for infection time, onset time, and
#'   hospitalization time (with 70% of hospitalizations set to NA)
#'
#' @importFrom dplyr mutate n if_else
#' @importFrom stats rgamma rlnorm rbinom
#'
#' @examples
#' add_delays(infection_times)
add_delays <- function(infection_times) {
  # Add random delays from appropriate probability distributions
  df <- infection_times |>
    mutate(
      # Gamma distribution for onset times
      onset_time = infection_time + rgamma(n(), shape = 5, rate = 1),
      # Lognormal distribution for hospitalisation times
      hosp_time = onset_time + rlnorm(n(), meanlog = 1.75, sdlog = 0.5)
    )

  # Set random 70% of hospitalization dates to NA (30% hospitalized)
  df <- df |>
    mutate(
      hosp_time = if_else(
        # use the binomial distribution for random binary outcomes
        rbinom(n = n(), size = 1, prob = 0.3) == 1,
        hosp_time,
        NA_real_
      )
    )

  return(df)
}
