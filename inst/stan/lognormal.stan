// lognormal_model.stan
data {
  int<lower=0> n; // number of data points
  array[n] real y; // data
}

parameters {
  real meanlog;
  real<lower=0> sdlog;
}

model {
  meanlog ~ normal(0, 10);  // prior distribution
  sdlog ~ normal(0, 10) T[0, ]; // prior distribution

  y ~ lognormal(meanlog, sdlog);
}
