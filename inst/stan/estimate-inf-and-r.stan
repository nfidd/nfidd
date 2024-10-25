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
  array[n] real<lower = 0> R;
}

transformed parameters {
  array[n] real infections = renewal(I0, R, gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  R ~ normal(1, 1) T[0, ];
  obs ~ poisson(onsets);
}
