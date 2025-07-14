test_that("summarise_lognormal correctly transforms lognormal parameters", {
  library(posterior)

  # Test parameters
  meanlog_true <- 1.75
  sdlog_true <- 0.5

  # Generate empirical mean and SD from Monte Carlo samples
  n_samples <- 100000
  samples <- rlnorm(n_samples, meanlog = meanlog_true, sdlog = sdlog_true)
  mean_empirical <- mean(samples)
  sd_empirical <- sd(samples)

  # Create mock posterior object
  mock_draws <- data.frame(
    meanlog = rep(meanlog_true, 1000),
    sdlog = rep(sdlog_true, 1000)
  )
  mock_posterior <- as_draws_df(mock_draws)

  # Test the function
  result <- summarise_lognormal(mock_posterior)

  # Extract values from summary table
  func_mean <- as.numeric(gsub("Mean   :", "", result[4, 1]))
  func_sd <- as.numeric(gsub("Mean   :", "", result[4, 2]))

  # Check that function output matches empirical values within 2%
  expect_lt(abs(func_mean - mean_empirical) / mean_empirical, 0.02)
  expect_lt(abs(func_sd - sd_empirical) / sd_empirical, 0.02)

  # Check analytical formula is correct
  mean_analytical <- exp(meanlog_true + 0.5 * sdlog_true^2)
  sd_analytical <- exp(meanlog_true + 0.5 * sdlog_true^2) *
    sqrt(exp(sdlog_true^2) - 1)

  expect_equal(func_mean, mean_analytical, tolerance = 0.01)
  expect_equal(func_sd, sd_analytical, tolerance = 0.01)
})
