extract_R_posteriors <- function(samples) {
  rw_posteriors <- samples |>
    gather_draws(infections[infection_day], R[infection_day]) |>
    group_by(infection_day, .variable) |>
    summarise(
      median = median(.value),
      lower = quantile(.value, 0.05),
      upper = quantile(.value, 0.95),
      .groups = "drop"
    ) |>
    mutate(infection_day = infection_day - 1)
  return(rw_posteriors)
}
