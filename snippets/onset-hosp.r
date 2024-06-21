# Load data
data(infection_times)

### first, choose random delays
df <- infection_times |>
  mutate(
    onset_time = infection_time + rgamma(n(), shape = 5, rate = 1),
    hosp_time = onset_time + rlnorm(n(), meanlog = 1.75, sdlog = 0.5)
  )
### next, set 70% of the hospitalization dates to NA because only 30∞ of cases
### are hospitalized
df <- df |>
  mutate(
    hosp_time = if_else(
      rbinom(n = n(), size = 1, prob = 0.3) == 1,
      hosp_time,
      NA_real_
    )
  )
