functions {
  #include "functions/geometric_random_walk.stan"
  #include "functions/observe_onsets_with_delay.stan"
  #include "functions/combine_obs_with_predicted_obs_rng.stan"
}

data {
  int n;                // number of days
  int m;                // number of reports
  array[n] int p;       // number of observations per day
  array[m] int obs;     // observed symptom onsets
  int d;                // number of reporting delays
}

transformed data{
  array[n] int P = to_int(cumulative_sum(p));
  array[n] int D = to_int(cumulative_sum(rep_array(d, n)));
}

transformed data{
  array[n] int P = to_int(cumulative_sum(p));
  array[n] int D = to_int(cumulative_sum(rep_array(d, n)));
}

parameters {
  real<lower=0> init_onsets;
  array[n-1] real rw_noise;
  real<lower=0> rw_sd;
  simplex[d] reporting_delay; // reporting delay distribution
}

transformed parameters {
  array[n] real onsets = geometric_random_walk(init_onsets, rw_noise, rw_sd);
  array[m] real onsets_by_report = observe_onsets_with_delay(onsets, reporting_delay, P, p);
}

model {
  // Prior
  init_onsets ~ normal(1, 1) T[0,];
  rw_noise ~ std_normal();
  rw_sd ~ normal(0, 0.1) T[0,];
  reporting_delay ~ dirichlet(rep_vector(1, d));
  // Likelihood
  obs ~ poisson(onsets_by_report);
}

generated quantities {
  array[d*n] real complete_onsets_by_report = observe_onsets_with_delay(onsets, reporting_delay, D, rep_array(d, n));
  array[n] int nowcast = combine_obs_with_predicted_obs_rng(obs, complete_onsets_by_report, P, p, d, D);
}

