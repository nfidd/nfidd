functions {
  #include "functions/convolve_with_delay.stan"
  #include "functions/renewal.stan"
  #include "functions/geometric_diff_ar.stan"
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
}

transformed data {
   int m = n + h;
}

parameters {
  real<lower = -1, upper = 1> init_R;         // initial reproduction number
  array[m-1] real rw_noise; // random walk noise
  real<lower = 0, upper = 1> rw_sd; // random walk standard deviation
  real<lower = 0, upper = 1> damp; // damping
}

transformed parameters {
  array[m] real R = geometric_diff_ar(init_R, rw_noise, rw_sd, damp);
  array[m] real <upper = 1e5> infections = renewal(I0, R, gen_time_pmf);
  array[m] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  init_R ~ normal(-.1, 0.5); // Approximately Normal(1, 0.5)
  rw_noise ~ std_normal();
  rw_sd ~ normal(0, 0.01) T[0,];
  damp ~ normal(0.5, 0.25) T[0, 1];
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
