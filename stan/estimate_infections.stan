functions {
  array[] real discretise_gamma(real shape, real rate, int max_delay) {
    array[max_delay + 1] real ret; // return array
    real norm; // normalising constant, to be calculated later
    // for the first element we integrate over [0, 1) because delays cannot be
    // negative
    ret[1] = gamma_cdf(1 | shape, rate);
    // for all other elements we use 2-day integration windows
    for (i in 2:(max_delay + 1)) {
      ret[i] = gamma_cdf(i | shape, rate) - gamma_cdf(i - 2 | shape, rate);
    }
    // normalise
    norm = sum(ret);
    for (i in 1:(max_delay + 1)) {
      ret[i] = ret[i] / norm;
    }
    return(ret);
  }

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
  real ip_shape;    // shape of incubation period
  real ip_rate;     // rate of incubation period
  int ip_max;       // max of incubation period
}

parameters {
  array[n] real<lower = 0> infections;
}

transformed parameters {
  array[ip_max + 1] real gamma_pmf = discretise_gamma(
    ip_shape, ip_rate, ip_max
  );
  array[n] real onsets = convolve_with_delay(infections, gamma_pmf);
}

model {
  // priors
  infections ~ normal(0, 10) T[0, ];
  obs ~ poisson(onsets);
}
