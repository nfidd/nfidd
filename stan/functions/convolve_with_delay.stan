array[] real convolve_with_delay(array[] real ts, array[] real delay) {
  // length of time series
  int n = num_elements(ts);
  int max_delay = num_elements(delay) - 1;
  array[n] real ret;
  for (i in 1:n) {
    int first_index = max(1, i - max_delay);
    int len = i - first_index + 1;
    array[len] real pmf = reverse(delay)[1:len];
    array[i - first_index + 1] real ts_segment = ts[first_index:i];
    ret[i] = dot_product(ts_segment, pmf);
  }
  return(round(ret));
}
