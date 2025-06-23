##' Reduces the number of symptom onsets by a delay distribution.
##'
##' This function assumes that symptom onsets are reported with a delay. It
##' reduces the number of symptom onsets by this delay, assuming that the last
##' element of the symptom onset vector is the day of reporting.
##'
##' @param onsets vector of symptom onsets
##' @param delay vector representing the cumulative distribution function (CDF)
##'   of the (deiscrete) delay distribution. The first element corresponds to a
##'   delay of 0, i.e. symptom onsets reported on the same day.
##' @return A vector of symptom onsets reduced by the delay distribution.
condition_onsets_by_report <- function(onsets, delay) {
  onsets_with_delay <- onsets
  for (i in 1:min(length(onsets), length(delay))) {
    onsets_with_delay[n - i + 1] <- onsets[n - i + 1] * delay[i]
  }
  onsets_with_Delay
}
