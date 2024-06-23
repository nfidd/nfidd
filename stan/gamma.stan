// gamma_model.stan
data {
  int<lower=0> N;
  array[N] real y;
}

parameters {
  real<lower=0> alpha;
  real<lower=0> beta;
}

model {
  alpha ~ normal(0, 10) T[0,];
  beta ~ normal(0, 10) T[0,];
  y ~ gamma(alpha, beta);
}
