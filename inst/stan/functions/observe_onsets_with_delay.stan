array[] real observe_onsets_with_delay(array[] real onsets, vector reporting_delay, array[] int P, array[] int p) {
  int n = num_elements(onsets);
  int m = sum(p);
  array[m] real onsets_by_report;
  for (i in 1:n) {
    int obs_index;
    if (i == 1) {
      obs_index = 0;
    } else{
      obs_index = P[i - 1];
    }
    for (j in 1:p[i]) {
      onsets_by_report[obs_index + j] = onsets[i] * reporting_delay[j];
    }
  }
  return onsets_by_report;
}
