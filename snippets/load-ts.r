data(infection_times)
df <- infection_times |>
  mutate(infection_day = floor(infection_time))
## infection time series
inf_ts <- df |>
  count(infection_day)
head(inf_ts)
