array[] int combine_obs_with_predicted_obs_rng(array[] int obs, array[] real complete_onsets_by_report, array[] int P, array[] int p, int d, array[] int D) {
    int n = num_elements(p);
    array[n] int reported_onsets = rep_array(0, n);
    for (i in 1:n) {
      int missing_reports = d - p[i];
      int P_index = 0;
      int D_index = 0;
      if (i != 1) {
        P_index = P[i - 1];
        D_index = D[i - 1];
      }
      if (missing_reports != d) {
        for (j in 1:p[i]) {
          reported_onsets[i] += obs[P_index + j];
        }
      }
      if (missing_reports > 0) {
        for (j in 1:missing_reports) {
          reported_onsets[i] += poisson_rng(complete_onsets_by_report[D_index + p[i] + j]);
        }
      }
    }
    return reported_onsets;
  }
  