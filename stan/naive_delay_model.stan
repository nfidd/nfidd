data {
  int n; // number of data points (rows with hospiatlisation date)
  array[n] real onset_to_hosp; // onset to hospitalisation delays in the data
}

parameters {
   real meanlog; // parameter to be estimtated
   real<lower = 0> sdlog; // parameter to be estimated
}

model {
  meanlog ~ normal(0, 10); // prior distribution
  sdlog ~ normal(0, 10) T[0, ]; // prior distribution

  onset_to_hosp ~ lognormal(meanlog, sdlog); // likelihood
}
