functions {
  #include "functions/convolve_with_delay.stan"
  #include "functions/renewal.stan"
  #include "functions/observe_onsets_with_delay.stan"
}

data {
  int n;                // number of days
  int I0;              // number initially infected
  array[n] int obs;     // observed symptom onsets
  int gen_time_max;     // maximum generation time
  array[gen_time_max] real gen_time_pmf;  // pmf of generation time distribution
  int<lower = 1> ip_max; // max incubation period
  array[ip_max + 1] real ip_pmf;
  int report_max;       // max reporting delay
  array[report_max + 1] real report_cdf;
}

parameters {
  array[n] real noise;  // random walk noise
  real<lower = 0> rw_sd; // random walk standard deviation
}

transformed parameters {
  # R is now a transformed parameter as we construct it as a 
  # exponentiated non-centred random walk
  array[n] real<lower = 0> R = exp(cumsum(noise * rw_sd));
  array[n] real infections = renewal(I0, R, gen_time_pmf);
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
  array[n] real reports = observe_onsets_with_delay(onsets, report_cdf);
}

model {
  // priors
  noise ~ std_normal(
  rw_sd ~ std_normal();
  obs ~ poisson(reports);
}
