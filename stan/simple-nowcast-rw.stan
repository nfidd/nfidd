functions {
  #include "functions/geometric_random_walk.stan"
  #include "functions/condition_onsets_by_report.stan"
}

data {
  int n;                // number of days
  array[n] int obs;     // observed symptom onsets
  int report_max;       // max reporting delay
  array[report_max + 1] real report_cdf;
}

parameters {
  real<lower=0> init_onsets;
  array[n-1] real rw_noise;
  real<lower=0> rw_sd;
}

transformed parameters {
  array[n] real onsets = geometric_random_walk(init_onsets, rw_noise, rw_sd);
  array[n] real reported_onsets = condition_onsets_by_report(onsets, report_cdf);
}

model {
  init_onsets ~ lognormal(0, 1) T[0,];
  rw_noise ~ std_normal();
  rw_sd ~ normal(0, 5) T[0,];
  //Likelihood
  obs ~ poisson(reported_onsets);
}
