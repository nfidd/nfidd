functions {
  array[] real convolve_with_delay(array[] real ts, array[] real delay) {
    // length of time series
    int n = num_elements(ts);
    int max_delay = num_elements(delay) - 1;
    array[n] real ret;
    for (i in 1:n) {
      int first_index = max(1, i - max_delay);
      int len = i - first_index + 1;
      ret[i] = dot_product(
        ts[first_index:i], reverse(delay)[1:len]
      );
    }
    return(round(ret));
  }
}

data {
  int n;            // number of time days
  array[n] int obs; // observed onsets
  int<lower = 1> ip_max; // max incubation period
  // probability mass function of incubation period distribution (first index zero)
  array[ip_max + 1] real ip_pmf;
}

parameters {
  array[n] real<lower = 0> infections;
}

transformed parameters {
  array[n] real onsets = convolve_with_delay(infections, ip_pmf);
}

model {
  // priors
  infections ~ normal(0, 10) T[0, ];
  obs ~ poisson(onsets);
}
