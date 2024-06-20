functions {
  #include "functions/convolve_with_delay.stan"
  #include "functions/pop_bounded_renewal.stan"
}

data {
  int n;                // number of days
  int I0;              // number initially infected
  array[n] int obs;     // observed symptom onsets
  int gen_time_max;     // maximum generation time
  array[gen_time_max] real gen_time_pmf;  // pmf of generation time distribution
  int<lower = 1> ip_max; // max incubation period
  array[ip_max + 1] real ip_pmf;
  int h;                // number of days to forecast
  array[2] real N_prior;      // prior for total population
}

transformed data {
   int m = n + h;
}

parameters {
  real<lower = 0> R;    // initial reproduction number
  real<lower = 0> N;   // total population
}

transformed parameters {
  array[m] real infections = pop_bounded_renewal(I0, R, gen_time_pmf, N, m);
  array[m] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  R ~ normal(1, 0.5) T[0,];
  N ~ normal(N_prior[1], N_prior[2]) T[0,];
  obs ~ poisson(onsets[1:n]);
}

generated quantities {
  array[h] real forecast;
  if (h > 0) {
    for (i in 1:h) {
      forecast[i] = poisson_rng(onsets[n + i]);
    }
  }
}
