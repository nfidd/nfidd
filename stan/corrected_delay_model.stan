data {
  int n;
  array[n] real onset_to_hosp;
}

transformed data {
  array[n] real onset_to_hosp_upper;
  array[n] real onset_to_hosp_lower;

  for (i in 1:n) {
    onset_to_hosp_upper[i] = onset_to_hosp[i] + 1;
    onset_to_hosp_lower[i] = onset_to_hosp[i] - 1;
  }
}

parameters {
   real meanlog;
   real<lower = 0> sdlog;
}

model {
  // priors
  meanlog ~ normal(0, 10);
  sdlog ~ normal(0, 10);

  // likelihood
  for (i in 1:n) {
    if (onset_to_hosp_lower[i] > 0) {
      target += log(
        lognormal_cdf(onset_to_hosp_upper[i] | meanlog, sdlog) -
        lognormal_cdf(onset_to_hosp_lower[i] | meanlog, sdlog)
      );
    } else {
      target += lognormal_lcdf(onset_to_hosp_upper[i] | meanlog, sdlog);
    }
  }
}
