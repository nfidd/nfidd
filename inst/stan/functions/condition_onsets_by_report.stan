array[] real condition_onsets_by_report(array[] real onsets, array[] real delay) {
    // length of time series
    int n = num_elements(onsets);
    // length of delay
    int p = num_elements(delay);

    array[n] real onsets_with_delay = onsets;
    
    for (i in 1:min(p, n)) {
      onsets_with_delay[n - i + 1] *= delay[i];
    }
    return onsets_with_delay;
}