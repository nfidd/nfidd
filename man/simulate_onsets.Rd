% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulate_onsets.r
\name{simulate_onsets}
\alias{simulate_onsets}
\title{Simulate symptom onsets from daily infection counts}
\usage{
simulate_onsets(
  inf_ts,
  gen_time_pmf = make_gen_time_pmf(),
  ip_pmf = make_ip_pmf()
)
}
\arguments{
\item{inf_ts}{A data frame containing columns infection_day and infections,
as returned by `make_daily_infections()`.}

\item{gen_time_pmf}{A vector of probabilities representing the generation
time PMF, as returned by `make_gen_time_pmf()`.}

\item{ip_pmf}{A vector of probabilities representing the incubation period
PMF, as returned by `make_ip_pmf()`.}
}
\value{
A data frame with columns day, onsets, and infections containing
  the daily count of symptom onsets and infections
}
\description{
Simulate symptom onsets from daily infection counts
}
\examples{
gt_pmf <- make_gen_time_pmf()
ip_pmf <- make_ip_pmf()
simulate_onsets(make_daily_infections(infection_times), gt_pmf, ip_pmf)
}
