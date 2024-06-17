#
#
#
#
#
#
set.seed(123)
#
#
#
#
#
#
#
#
#
#
#
#
library("nfidd")
library("dplyr")
library("tidyr")
library("purrr")
library("ggplot2")
library("here")
library("cmdstanr")
library("tidybayes")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
df <- infection_times |>
  mutate(
    onset_time = infection_time + rgamma(n(), shape = 5, rate = 1),
    report_time = onset_time + rlnorm(n(), meanlog = 1, sdlog = 0.5)
  )
#
#
#
#
#
#
cutoff <- 41
df_co <- df |>
  filter(report_time < cutoff)

df_on <- df |>
  filter(onset_time < cutoff)
#
#
#
#
#
## create time series of onsets and reports
df_co <- df_co |>
  transmute(
    infecton_day = floor(infection_time),
    onset_day = floor(onset_time),
    report_day = floor(report_time)
  )

infection_ts <- df_co |>
  count(day = infecton_day, name = "infections")
onset_ts <- df_co |>
  count(day = onset_day, name = "onsets")
reports_ts <- df_co |>
  count(day = report_day, name = "reports")

all_days <- expand_grid(day = seq(0, cutoff - 1)) |>
  full_join(infection_ts, by = "day") |>
  full_join(onset_ts, by = "day") |>
  full_join(reports_ts, by = "day") |>
  replace_na(list(onsets = 0, reports = 0))
#
#
#
#
#
combined <- all_days |>
  pivot_longer(c(onsets, reports, infections), names_to = "variable")
ggplot(combined, aes(x = day, y = value)) +
  facet_grid(~ variable) +
  geom_col()
#
#
#
#
#
#
#
#
#
final <- df |>
  transmute(onset_day = floor(onset_time))
final_onset_ts <- final |>
  count(day = onset_day, name = "onsets")
final_all_days <- expand_grid(day = seq(0, max(final_onset_ts$day))) |>
  full_join(final_onset_ts, by = "day") |>
  replace_na(list(onsets = 0)) |>
  mutate(cutoff = "final")
intermediate <- combined |>
  filter(variable == "onsets") |>
  select(-variable) |>
  rename(onsets = value) |>
  mutate(cutoff = "40 days")
combined_cutoffs <- rbind(
  intermediate,
  final_all_days
)
ggplot(combined_cutoffs, aes(x = day, y = onsets, colour = cutoff)) +
  geom_line() +
  scale_colour_brewer(palette = "Dark2") +
  geom_vline(xintercept = cutoff, linetype = "dashed")
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
proportion_reported <- plnorm(1:15, 1, 0.5)
plot(proportion_reported)
#
#
#
#
#
#
#
source(here::here("snippets", "simulate-onsets.r"))
reported_onset_df <- onset_df |>
  filter(day < 40) |>
  mutate(proportion_reported = c(rep(1, n() - 15), rev(proportion_reported)),
         reported_onsets = map_dbl(onsets * proportion_reported, \(x) rpois(1, x)) 
  )
tail(reported_onset_df)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
mod <- cmdstan_model(here("stan", "simple-nowcast.stan"), include_paths = here("stan"))
mod$print(line_numbers = TRUE)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
data <- list(
  n = nrow(reported_onset_df) - 1,
  obs = reported_onset_df$reported_onsets[-1],
  report_max = length(proportion_reported) - 1,
  report_cdf = proportion_reported 
)
simple_nowcast_fit <- mod$sample(
  data = data, parallel_chains = 2, refresh = 0, show_exceptions = FALSE, show_messages = FALSE
)
simple_nowcast_fit
#
#
#
#
#
nowcast_onsets <- simple_nowcast_fit |>
  gather_draws(onsets[day]) |>
  group_by(day, .variable) |>
  summarise(
    median = median(.value),
    lower = quantile(.value, 0.05),
    upper = quantile(.value, 0.95),
    .groups = "drop"
  ) |>
  mutate(day = day + 1)
#
#
#
reported_onset_df |> 
  filter(day > 1) |>
  left_join(nowcast_onsets, by = "day") |>
  ggplot(aes(x = day, y = onsets)) +
  geom_col() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5) +
  geom_line(aes(y = median))
#
#
#
#
#
#
#
#
#
#
#
#
#
rw_mod <- cmdstan_model(here("stan", "simple-nowcast-rw.stan"))
rw_mod$print(line_numbers = TRUE)
#
#
#
#
#
rw_nowcast_fit <- rw_mod$sample(
  data = data, parallel_chains = 2, refresh = 0, show_exceptions = FALSE, show_messages = FALSE
)
rw_nowcast_fit
#
#
#
nowcast_onsets <- simple_nowcast_fit |>
  gather_draws(onsets[day]) |>
  group_by(day, .variable) |>
  summarise(
    median = median(.value),
    lower = quantile(.value, 0.05),
    upper = quantile(.value, 0.95),
    .groups = "drop"
  ) |>
  mutate(day = day + 1)
#
#
#
reported_onset_df |> 
  filter(day > 1) |>
  left_join(nowcast_onsets, by = "day") |>
  ggplot(aes(x = day, y = onsets)) +
  geom_col() +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.5) +
  geom_line(aes(y = median))
#
#
#
#
#
#
#
gen_time_pmf
#
#
#
#
#
ip_pmf
#
#
#
#
#
#
rt_mod <- cmdstan_model(here("stan", "estimate-r-rw-with-simple-nowcast.stan"))
rt_mod$print(line_numbers = TRUE)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
data <- list(
  n = nrow(reported_onset_df) - 1,
  obs = reported_onset_df$onsets[-1],
  I0 = reported_onset_df$infections[1],
  gen_time_max = length(gen_time_pmf),
  gen_time_pmf = gen_time_pmf,
  ip_max = length(ip_pmf) - 1,
  ip_pmf = ip_pmf,
  report_max = length(reporting_delay) - 1,
  report_cdf = rep(1,  length(reporting_delay))
)
rt_nowcast_fit <- rt_mod$sample(
  data = data
)
rt_nowcast_fit
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
