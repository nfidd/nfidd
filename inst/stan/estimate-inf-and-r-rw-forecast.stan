functions {
  #include "functions/convolve_with_delay.stan"
  #include "functions/renewal.stan"
  #include "functions/geometric_random_walk.stan"
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

parameters {
  real<lower = 0> init_R;         // initial reproduction number
  array[n-1] real rw_noise; // random walk noise
  real<lower = 0, upper = 1> rw_sd; // random walk standard deviation
}

transformed parameters {
  array[n] real R = geometric_random_walk(init_R, rw_noise, rw_sd);
  array[n] real infections = renewal(I0, R, gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  init_R ~ normal(1, 0.25) T[0, ];
  rw_noise ~ std_normal();
  rw_sd ~ normal(0, 0.05) T[0,];
  obs ~ poisson(onsets[1:n]);
}
generated quantities {
  array[h] real forecast;
  if (h > 0) {
    array[n + h - 1] real f_rw_noise;
    for (i in 1:(n-1)) {
      f_rw_noise[i] = rw_noise[i];
    }
    for (i in n:(n + h - 1)) {
      f_rw_noise[i] = normal_rng(0, 1);
    }
    array[h + n] real f_R = geometric_random_walk(init_R, f_rw_noise, rw_sd);
    array[h + n] real f_infections = renewal(I0, f_R, gen_time_pmf);
    array[h + n] real f_onsets = convolve_with_delay(f_infections, ip_pmf);
    for (i in 1:h) {
      forecast[i] = poisson_rng(f_onsets[n + i]);
    }
  }
}
