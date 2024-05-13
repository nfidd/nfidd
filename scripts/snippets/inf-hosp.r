## first, choose random delays
inf_hosp <- infection_times |>
  mutate(
    incubation_period = rgamma(n(), shape = 5, rate = 1),
    onset_to_hosp = rlnorm(n(), meanlog = 1, sdlog = 1),
    infection_date = as.Date(start_date + infection_time),
    onset_date = as.Date(start_date + infection_time + incubation_period),
    hosp_date =
      as.Date(start_date + infection_time + incubation_period + onset_to_hosp)
  )
## next, set 70% of the hospitalization dates to NA because only 30∞ of cases
## are hospitalized
df <- inf_hosp |>
  mutate(
    hosp_date = if_else(
      rbinom(n = n(), size = 1, p = 0.3) == 1,
      hosp_date,
      as.Date(NA_character_))
  )
