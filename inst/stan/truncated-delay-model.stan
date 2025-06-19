data {
  int<lower = 0> n;
  array[n] real<lower = 0> onset_to_hosp;
  array[n] real<lower = 0> time_since_onset;
}

parameters {
  real meanlog;
  real<lower = 0> sdlog;
}

model {
  meanlog ~ normal(0, 10);
  sdlog ~ normal(0, 10) T[0, ];

  for (i in 1:n) {
    onset_to_hosp[i] ~ lognormal(meanlog, sdlog) T[0, time_since_onset[i]];
  }
}
