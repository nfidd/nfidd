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
make_forecast_on_day <- function(
  mod, onset_df, origin_day, horizon, gen_time_pmf, ip_pmf, data_to_list, ...
) {

  message("Fitting and forecasting for origin day: ", origin_day)

  train_df <- onset_df |>
    filter(day <= origin_day)

  data <- data_to_list(train_df, horizon, gen_time_pmf, ip_pmf)

  fit <- mod$sample(
    data = data, chains = 4, parallel_chains = 4, adapt_delta = 0.95,
    max_treedepth = 15, iter_warmup = 500, iter_sampling = 500, ...
  )

  fit |>
    gather_draws(forecast[day]) |>
    filter(!is.na(.value)) |>
    slice_head(n = 1000) |>
    mutate(horizon = day) |>
    mutate(day = day + origin_day) |>
    mutate(origin_day = origin_day) |>
    mutate(.draw = seq_len(n())) |>
    select(-.chain, -.iteration)
}

# define a forecast horizon
horizon <- 14

origin_days <- onset_df |>
  filter(day <= max(day) - horizon) |>
  filter(day > 21) |>
  pull(day)

# create forecasts every 7 days
origin_days <- origin_days[seq(1, length(origin_days), 7)]

# load the model
rw_mod <- nfidd_cmdstan_model("estimate-inf-and-r-rw-forecast")

data_to_list_rw <- function(train_df, horizon, gen_time_pmf, ip_pmf) {
  list(
    n = nrow(train_df),
    I0 = 1,
    obs = train_df$onsets,
    gen_time_max = length(gen_time_pmf),
    gen_time_pmf = gen_time_pmf,
    ip_max = length(ip_pmf) - 1,
    ip_pmf = ip_pmf,
    h = horizon
  )
}

rw_forecasts <- origin_days |>
  map_dfr(
    \(x) {
      make_forecast_on_day(
        rw_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf,
        data_to_list_rw, init = \() list(init_R = 1, rw_sd = 0.01)
      )
    }
  ) |>
  mutate(model = "Random walk") |>
  ungroup()

usethis::use_data(rw_forecasts, overwrite = TRUE)

# AR model forecass
stat_mod <- nfidd_cmdstan_model("statistical-r")

stat_forecasts <- origin_days |>
  map_dfr(
    \(x) {
      make_forecast_on_day(
        stat_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf, data_to_list_rw,
        init = \() list(init_R = 1, rw_sd = 0.01)
      )
    }
  ) |>
  mutate(model = "Statistical") |>
  ungroup()

usethis::use_data(stat_forecasts, overwrite = TRUE)

# Mechanistic model forecasts

mech_mod <- nfidd_cmdstan_model("mechanistic-r")

data_to_list_mech <- function(train_df, horizon, gen_time_pmf, ip_pmf) {
  data <- data_to_list_rw(train_df, horizon, gen_time_pmf, ip_pmf)
  data$N_prior <- c(10000, 2000)
  data
}

mech_forecasts <- origin_days |>
  map_dfr(
    \(x) {
      make_forecast_on_day(
        mech_mod, onset_df, x, horizon, gen_time_pmf, ip_pmf, data_to_list_mech
      )
    }
  ) |>
  mutate(model = "Mechanistic") |>
  ungroup()

usethis::use_data(mech_forecasts, overwrite = TRUE)
