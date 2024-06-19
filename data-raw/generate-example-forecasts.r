library("dplyr")
library("tidyr")
library("here")
library("cmdstanr")
library("tidybayes")
library("purrr")

# load the model
rw_mod <- cmdstan_model(here("stan", "estimate-inf-and-r-rw.stan"))

# simulate data
source(here::here("snippets", "simulate-onsets.r"))

# define a function to fit and forecast for a single date
forecast_target_day <- function(
  mod, onset_df, target_day, horizon, gen_time_pmf, ip_pmf
) {

  message("Fitting and forecasting for target day: ", target_day)

  train_df <- onset_df |>
    filter(day <= target_day)

  test_df <- onset_df |>
    filter(day > target_day, day <= target_day + horizon)

  data <- list(
    n = nrow(train_df),
    I0 = 1,
    obs = train_df$onsets,
    gen_time_max = length(gen_time_pmf),
    gen_time_pmf = gen_time_pmf,
    ip_max = length(ip_pmf) - 1,
    ip_pmf = ip_pmf,
    h = horizon
  )

  fit <- mod$sample(
    data = data, chains = 4, parallel_chains = 4, adapt_delta = 0.95,
    max_treedepth = 12, iter_warmup = 1000, iter_sampling = 250,
  )

  forecast <- fit |>
    gather_draws(forecast[day]) |>
    mutate(horizon = day) |>
    mutate(day = day + target_day) |>
    mutate(target_day = target_day)
  return(forecast)
}

# define a forecast horizon
horizon <- 14

target_days <- onset_df |>
  filter(day <= max(day) - horizon) |>
  filter(day > 21) |>
  pull(day)

# only keep forecasts from every 7 days
target_days <- target_days[seq(1, length(target_days), 7)]


forecasts <- target_days |>
  map_dfr(
    \(x) forecast_target_day(rw_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf)
  )
