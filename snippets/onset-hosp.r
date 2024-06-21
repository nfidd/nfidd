# Simulate times for symptom onset and hospitalisation for each infection

### Load data
data(infection_times)

### Add random delays to each infection from the appropriate probability distributions
df <- infection_times |>
  mutate(
    # Gamma distribution for onset times
    onset_time = infection_time + rgamma(n(), shape = 5, rate = 1),
    # Lognormal distribution for hospitalisation times
    hosp_time = onset_time + rlnorm(n(), meanlog = 1.75, sdlog = 0.5)
  )
### Set a random 70% of the hospitalization dates to NA,
### because only 30% of cases are hospitalized
df <- df |>
  mutate(
    hosp_time = if_else(
      # use the binomial distribution for random binary outcomes
      rbinom(n = n(), size = 1, p = 0.3) == 1,
      hosp_time,
      NA_real_
    )
  )
