functions {
  #include "functions/convolve_with_delay.stan"
}

data {
  int n;            // number of time days
  array[n] int obs; // observed onsets
  int<lower = 1> ip_max; // max incubation period
  // probability mass function of incubation period distribution (first index zero)
  array[ip_max + 1] real ip_pmf;
}

parameters {
  array[n] real<lower = 0> infections;
}

transformed parameters {
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  infections ~ normal(0, 10) T[0, ];
  obs ~ poisson(onsets);
}
