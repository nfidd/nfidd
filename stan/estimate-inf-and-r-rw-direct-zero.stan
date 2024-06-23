functions {
  #include "functions/convolve_with_delay.stan"
  #include "functions/renewal.stan"
}

data {
  int n;                // number of days
  int I0;              // number initially infected
  array[n] int obs;     // observed symptom onsets
  int gen_time_max;     // maximum generation time
  array[gen_time_max] real gen_time_pmf;  // pmf of generation time distribution
  int<lower = 1> ip_max; // max incubation period
  array[ip_max + 1] real ip_pmf;
}

parameters {
  real logR0;         // logarithm of reproduction number
  array[n - 1] real rw;         // logarithm of reproduction number
  real<lower = 0> rw_sd; // random walk standard deviation
}

transformed parameters {
  array[n] real R = to_array_1d(exp(logR0 + append_row(0, to_vector(rw))));
  array[n] real infections = renewal(I0, R, gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  logR0 ~ normal(0, 0.5);
  for (i in 1:(n - 1)) {
    rw[i] ~ normal(i == 1 ? 0 : rw[i - 1], rw_sd);
  }
  rw_sd ~ normal(0, 1) T[0,];
  obs ~ poisson(onsets);
}
