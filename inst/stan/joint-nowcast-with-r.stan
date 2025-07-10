functions {
  #include "functions/geometric_random_walk.stan"
  #include "functions/renewal.stan"
  #include "functions/convolve_with_delay.stan"
  #include "functions/observe_onsets_with_delay.stan"
  #include "functions/combine_obs_with_predicted_obs_rng.stan"
}

data {
  int n;                // number of days
  int m;                // number of reports
  array[n] int p;       // number of observations per day
  array[m] int obs;     // observed symptom onsets
  int d;                // number of reporting delays
  int gen_time_max;     // maximum generation time
  array[gen_time_max] real gen_time_pmf;  // pmf of generation time distribution
  int<lower = 1> ip_max; // max incubation period
  array[ip_max + 1] real ip_pmf;
  int h;                // number of days to forecast
}

transformed data{
  array[n] int P = to_int(cumulative_sum(p));
  array[n] int D = to_int(cumulative_sum(rep_array(d, n)));
}

parameters {
  real<lower = 0> init_I;         // initial number of infected
  real<lower = 0> init_R;         // initial reproduction number
  array[n-1] real rw_noise;       // random walk noise
  real<lower = 0> rw_sd; // random walk standard deviation
  simplex[d] reporting_delay; // reporting delay distribution
}

transformed parameters {
  array[n] real R = geometric_random_walk(init_R, rw_noise, rw_sd);
  array[n] real infections = renewal(init_I, R, gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
  array[m] real onsets_by_report = observe_onsets_with_delay(onsets, reporting_delay, P, p);
}

model {
  // Prior
  init_I ~ lognormal(-1, 1);
  init_R ~ normal(1, 0.5) T[0, ];
  rw_noise ~ std_normal();
  rw_sd ~ normal(0, 0.05) T[0,];
  reporting_delay ~ dirichlet(rep_vector(1, d));
  // Likelihood
  obs ~ poisson(onsets_by_report);
}

generated quantities {
  array[d*n] real complete_onsets_by_report = observe_onsets_with_delay(onsets, reporting_delay, D, rep_array(d, n));
  array[n] int nowcast = combine_obs_with_predicted_obs_rng(obs, complete_onsets_by_report, P, p, d, D);

  // Forecast the underlying onsets
  array[h] real forecast;
  if (h > 0) {
    array[h + n - 1] real f_rw_noise;
    for (i in 1:n-1) {
      f_rw_noise[i] = rw_noise[i];
    }
    for (i in n:(h + n - 1)) {
      f_rw_noise[i] = normal_rng(0, 1);
    }
    array[h + n] real f_R = geometric_random_walk(init_R, f_rw_noise, rw_sd);
    array[h + n] real f_infections = renewal(init_I, f_R, gen_time_pmf);
    array[h + n] real f_onsets = convolve_with_delay(f_infections, ip_pmf);
    for (i in 1:h) {
      forecast[i] = poisson_rng(f_onsets[n + i]);
    }
  }
}

