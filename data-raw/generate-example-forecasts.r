library("dplyr")
library("tidyr")
library("cmdstanr")
library("tidybayes")
library("purrr")
library("usethis")
library("nfidd")

set.seed(12345)

# simulate data
gen_time_pmf <- make_gen_time_pmf()
ip_pmf <- make_ip_pmf()
onset_df <- simulate_onsets(
  make_daily_infections(infection_times), gen_time_pmf, ip_pmf
)

# define a function to fit and forecast for a single date
forecast_target_day <- function(
  mod, onset_df, target_day, horizon, gen_time_pmf, ip_pmf, data_to_list, ...
) {

  message("Fitting and forecasting for target day: ", target_day)

  train_df <- onset_df |>
    filter(day <= target_day)

  test_df <- onset_df |>
    filter(day > target_day, day <= target_day + horizon)

  data <- data_to_list(train_df, horizon, gen_time_pmf, ip_pmf)

  fit <- mod$sample(
    data = data, chains = 4, parallel_chains = 4, adapt_delta = 0.95,
    max_treedepth = 15, iter_warmup = 1000, iter_sampling = 500, ...)

  forecast <- fit |>
    gather_draws(forecast[day]) |>
    filter(!is.na(.value)) |>
    slice_head(n = 1000) |>
    mutate(horizon = day) |>
    mutate(day = day + target_day) |>
    mutate(target_day = target_day) |>
    mutate(.draw = 1:n()) |>
    select(-.chain, -.iteration)
  return(forecast)
}

# define a forecast horizon
horizon <- 14

target_days <- onset_df |>
  filter(day <= max(day) - horizon) |>
  filter(day > 21) |>
  pull(day)

# create forecasts every 7 days
target_days <- target_days[seq(1, length(target_days), 7)]

# load the model
rw_mod <- nfidd_cmdstan_model("estimate-inf-and-r-rw-forecast")

data_to_list_rw <- function(train_df, horizon, gen_time_pmf, ip_pmf) {
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
  return(data)
}

rw_forecasts <- target_days |>
  map_dfr(
    \(x) forecast_target_day(
      rw_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf,
      data_to_list_rw, init = \() list(init_R = 0, rw_sd = 0.01)
    )
  ) |>
  mutate(model = "Random walk")

usethis::use_data(rw_forecasts, overwrite = TRUE)

# AR model forecass
stat_mod <- nfidd_cmdstan_model("statistical-r")

stat_forecasts <- target_days |>
  map_dfr(
    \(x) forecast_target_day(
      stat_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf, data_to_list_rw,
      init = \() list(init_R = 0, rw_sd = 0.01)
    )
  ) |>
  mutate(model = "Statistical")

usethis::use_data(stat_forecasts, overwrite = TRUE)

# Mechanistic model forecasts

mech_mod <- nfidd_cmdstan_model("mechanistic-r")

data_to_list_mech <- function(train_df, horizon, gen_time_pmf, ip_pmf) {
  data <- data_to_list_rw(train_df, horizon, gen_time_pmf, ip_pmf)
  data$N_prior <- c(10000, 2000)
  return(data)
}

mech_forecasts <- target_days |>
  map_dfr(
    \(x) forecast_target_day(
      mech_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf, data_to_list_mech
    )
  ) |>
  mutate(model = "Mechanistic")

usethis::use_data(mech_forecasts, overwrite = TRUE)
