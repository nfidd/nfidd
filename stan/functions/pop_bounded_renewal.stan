array[] real pop_bounded_renewal(real I0, array[] real R, array[] real gen_time, real N) {
  // length of time series
  int n = num_elements(R);
  int max_gen_time = num_elements(gen_time);
  array[n + 1] real I;
  I[1] = I0;
  real S = N - I0;
  
  for (i in 1:n) {
    int first_index = max(1, i - max_gen_time + 1);
    int len = i - first_index + 1;
    array[len] real I_segment = I[first_index:i];
    array[len] real gen_pmf = reverse(gen_time[1:len]);
    I[i + 1] = S / N * dot_product(I_segment, gen_pmf) * R[i];
    S = S - I[i + 1];
  }
  return(I[2:(n + 1)]);
}
