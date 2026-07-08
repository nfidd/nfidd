array[] real convolve_with_delay(array[] real ts, array[] real delay) {
  int n = num_elements(ts);
  int max_delay = num_elements(delay) - 1; // delay starts at day 0
  array[n] real convolved;
  for (i in 1:n) {
    // window of the time series contributing to the current time point
    int first_index = max(1, i - max_delay);
    int len = i - first_index + 1;
    array[len] real segment = ts[first_index:i];
    // reverse the (possibly truncated) pmf to align with the segment
    array[len] real pmf = reverse(delay[1:len]);
    convolved[i] = dot_product(segment, pmf);
  }
  return convolved;
}
