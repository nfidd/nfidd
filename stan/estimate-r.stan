functions {
  #include "functions/renewal.stan")
}

data {
  int n;                // number of days
  int I0;              // number initially infected
  array[n] int obs;     // observed infections
  int gen_time_max;     // max of incubation period
  arrray [gen_time_max + 1] real gen_time_pmf;  // shape of incubation period
}

parameters {
  array[n] real<lower = 0> R;
}

transformed parameters {
  array[n] real infections = renewal(I0, R, gen_time_pmf);
}

model {
  // priors
  R ~ normal(1, 3) T[0, ];
  obs ~ poisson(infections);
}
