// lognormal_model.stan
data {
  int<lower=0> N;
  real y[N];
}

parameters {
  real mu_log;
  real<lower=0> sigma_log;
}

model {
  mu_log ~ normal(0, 10);
  sigma_log ~ normal(0, 10);
  y ~ lognormal(mu_log, sigma_log);
}
