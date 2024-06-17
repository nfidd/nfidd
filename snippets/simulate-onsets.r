source(here::here("snippets", "load-ts.r"))
source(here::here("functions", "censored-delay-pmf.r"))
source(here::here("functions", "convolve-with-delay.r"))

gen_time_pmf <- censored_delay_pmf(rgamma, max = 14, shape = 4, rate = 1)
gen_time_pmf <- gen_time_pmf[-1] ## remove first element
gen_time_pmf <- gen_time_pmf / sum(gen_time_pmf) ## renormalise

ip_pmf <- censored_delay_pmf(rgamma, max = 14, shape = 5, rate = 1)
onsets <- convolve_with_delay(inf_ts$infections, ip_pmf)
onsets <- purrr::map_dbl(onsets, \(x) rpois(1, x))
onset_df <- tibble(day = seq_along(onsets), onsets = onsets) |>
  left_join(
    inf_ts |> select(day = infection_day, infections),
    by = "day"
  )