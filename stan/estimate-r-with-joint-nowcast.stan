functions {
  #include "functions/convolve_with_delay.stan"
  #include "functions/renewal.stan"
  #include "functions/observe_onsets_with_delay.stan"
  #include "functions/combine_obs_with_predicted_obs.stan"
}

data {
  int n;                // number of days
  int m;                // number of observations
  array[n] int p;       // number of observations per day
  int I0;              // number initially infected
  array[m] int obs;     // observed symptom onsets
  int gen_time_max;     // maximum generation time
  array[gen_time_max] real gen_time_pmf;  // pmf of generation time distribution
  int<lower = 1> ip_max; // max incubation period
  array[ip_max + 1] real ip_pmf;
  int d
}

parameters {
  real<lower = 0> init_R; // initial reproduction number
  array[n-1] real noise;  // random walk noise
  real<lower = 0> rw_sd; // random walk standard deviation
  simplex[d] reporting_delay; // reporting delay distribution
}

transformed parameters {
  array[n] real R = geometric_random_walk(init_R, rw_noise, rw_sd);
  array[n] real infections = renewal(I0, R, gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
  array[m] real onsets_by_report = observe_onsets_with_delay(onsets, reporting_delay, p);
}

model {
  // priors
  init_R ~ lognormal(1, 1);
  noise ~ std_normal();
  rw_sd ~ normal(0, 0.1);
  reporting_delay ~ dirichlet()
  // likelihood
  obs ~ poisson(onsets_by_report);
}

generated quantities {
  array[d*n] real complete_onsets_by_report = observe_onsets_with_delay(onsets, reporting_delay, rep_array(d, n));
  array[n] int nowcast = combine_obs_with_predicted_obs(obs, complete_onsets_by_report, p);
}
