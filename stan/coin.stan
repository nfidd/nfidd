data {
  int<lower = 1> N;  // integer, minimum 1
  int<lower = 0> x; // integer, minimum 0
}

parameters {
  real<lower = 0, upper = 1> theta; // real, between 0 and 1
}

model {
  // Uniform prior
  theta ~ uniform(0, 1);
  // Binomial likelihood
  x ~ binomial(N, theta);
}
