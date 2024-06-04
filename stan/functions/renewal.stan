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
