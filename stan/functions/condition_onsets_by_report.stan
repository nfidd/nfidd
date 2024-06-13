array[] real condition_onsets_by_report(array[] onsets, array[] delay) {
    // length of time series
    n = num_elements(onsets);
    // length of delay
    p = num_elements(delay);

    array[n] onsets_with_delay;
    int m = min(1, n-p);

    if (n > p) {
      onsets_with_delay[1:m] = onsets[1:m];
    }
    
    onsets_with_delay[m:n] = onsets[m:n] .* delay[max(1, p - n):p];
    
    return onsets_with_delay;
}