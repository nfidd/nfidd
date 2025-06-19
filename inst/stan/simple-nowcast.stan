functions {
  #include "functions/condition_onsets_by_report.stan"
}

data {
  int n;                // number of days
  array[n] int obs;     // observed symptom onsets
  int report_max;       // max reporting delay
  array[report_max + 1] real report_cdf;
}

parameters {
  array[n] real<lower = 0> onsets;
}

transformed parameters {
  array[n] real reported_onsets = condition_onsets_by_report(onsets, report_cdf);
}

model {
  onsets ~ normal(5, 20) T[0,];
  // Likelihood
  obs ~ poisson(reported_onsets);
}
