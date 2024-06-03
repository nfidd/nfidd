data {
  int<lower = 0> n;
  array[n] int<lower = 0> onset_to_hosp;
}

parameters {
  real meanlog;
  real<lower = 0> sdlog;
  array[n] real<lower = 0, upper = 1> onset_time;
  array[n] real<lower = 0, upper = 1> hosp_time;
}

transformed parameters {
  array[n] real<lower = 0> true_onset_to_hosp;
  for (i in 1:n) {
    true_onset_to_hosp[i] = onset_to_hosp[i] + hosp_time[i] - onset_time[i];
  }
}

model {
  meanlog ~ normal(0, 10);
  sdlog ~ normal(0, 10) T[0, ];
  onset_time ~ beta(1, 1);
  hosp_time ~ beta(1, 1);

  true_onset_to_hosp ~ lognormal(meanlog, sdlog);
}
