library("epichains")
library("usethis")
library("dplyr")
library("ggplot2")

rgamma_max <- function(n, ..., max) {
  ret <- rep(NA_real_, n)
  while (anyNA(ret)) {
    todo <- which(is.na(ret))
    ret[todo] <- rgamma(length(todo), ...)
    ret[ret > max] <- NA_real_
  }
  return(ret)
}

set.seed(12345)
infection_times <- simulate_chains(
  index_cases = 1, offspring_dist = rpois, statistic = "size", lambda = 1.5,
  pop = 1000, generation_time = function(n) rgamma_max(n, shape = 4, max = 14)
) |>
  select(infection_time = time) |>
  as.data.frame()

usethis::use_data(infection_times, overwrite = TRUE)
