library("epichains")
library("usethis")
library("dplyr")
library("ggplot2")

set.seed(12345)
infection_times <- simulate_chains(
  index_cases = 1, offspring_dist = rpois, statistic = "size", lambda = 1.5,
  pop = 1000, generation_time = function(n) rgamma(n, shape = 4)
) |>
  select(infection_time = time) |>
  as.data.frame()

usethis::use_data(infection_times, overwrite = TRUE)
