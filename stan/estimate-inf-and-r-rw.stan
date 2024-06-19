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
  array[n] real logR;         // logarithm of reproduction number
  real<lower = 0> rw_sd; // random walk standard deviation
}

transformed parameters {
  array[n] real infections = renewal(I0, exp(logR), gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  logR[1] ~ normal(0, 0.5);
  for (i in 2:n) {
    logR[i] ~ normal(logR[i - 1], rw_sd);
  }
  rw_sd ~ normal(0, 0.05) T[0,];
  obs ~ poisson(onsets);
}
