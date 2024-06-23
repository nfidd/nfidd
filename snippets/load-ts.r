## Load data
data(infection_times)
## Censor infection times to days
df <- infection_times |>
  transmute(infection_day = floor(infection_time))

## Summarise infections as a time series by day
inf_ts <- df |>
  count(infection_day, name = "infections")
head(inf_ts)

## fill data frame with zeroes for days without infection
all_days <- expand(
  df, infection_day = seq(min(infection_day), max(infection_day))
)
inf_ts <- all_days |>
  full_join(inf_ts, by = join_by(infection_day)) |>
  replace_na(list(infections = 0))
