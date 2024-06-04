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

  array[] real renewal(real I0, array[] real R, array[] real gen_time) {
    // length of time series
    int n = num_elements(R);
    int max_gen_time = num_elements(gen_time);
    array[n + 1] real I;
    I[1] = I0;
    for (i in 1:n) {
      int first_index = max(1, i - max_gen_time + 1);
      int len = i - first_index + 1;
      I[i + 1] = dot_product(
        I[first_index:i], reverse(gen_time)[1:len]
      ) * R[i];
    }
    return(I[2:(n + 1)]);
  }
}

data {
  int n;                // number of days
  int I0;              // number initially infected
  array[n] int obs;     // observed infections
  real gen_time_shape;  // shape of incubation period
  real gen_time_rate;   // rate of incubation period
  int gen_time_max;     // max of incubation period
}

parameters {
  array[n] real<lower = 0> R;
}

transformed parameters {
  array[gen_time_max + 1] real gen_time_pmf = discretise_gamma(
    gen_time_shape, gen_time_rate, gen_time_max
  );
  array[n] real infections = renewal(I0, R, gen_time_pmf);
}

model {
  // priors
  R ~ normal(1, 1) T[0, ];
  obs ~ poisson(infections);
}
