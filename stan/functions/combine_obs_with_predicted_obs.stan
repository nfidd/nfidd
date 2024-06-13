array[] int combine_obs_with_predicted_obs(array[] int obs, array[] real complete_onsets_by_report, array[] int p, int d) {
    n = num_elements(p);
    array[n] int reported_onsets = rep_array(0, n);
    for (i in 1:n) {
      int obs_index;
      if (i == 1) {
        obs_index = 1;
      } else {
        obs_index = cumsum(p[i - 1]);
      }
      int missing_reports = d - p[i];
      if (missing_reports != d) {
        reported_onsets[i] += obs[(obs_index + 1):(obs_index + p[i])]
      }
      if (missing_reports > 0) {
        for (j in 1:missing_reports) {
          reported_onsets[i] += poisson_rng(complete_onsets_by_report[obs_index + j]);
        }
      }
    }
    return reported_onsets;
  }
  