array[] real renewal(real I0, array[] real R, array[] real gen_time) {
  int n = num_elements(R);
  int max_gen_time = num_elements(gen_time); // gen_time starts at day 1
  array[n + 1] real I; // infections, with I0 prepended at index 1
  I[1] = I0;
  for (i in 1:n) {
    // window of past infections contributing to the current time point
    int first_index = max(1, i - max_gen_time + 1);
    int len = i - first_index + 1;
    array[len] real segment = I[first_index:i];
    // reverse the (possibly truncated) generation time to align with the segment
    array[len] real gen_pmf = reverse(gen_time[1:len]);
    // renewal equation: convolve past infections with the generation time, scale by R
    I[i + 1] = dot_product(segment, gen_pmf) * R[i];
  }
  return I[2:(n + 1)]; // drop the prepended I0
}
