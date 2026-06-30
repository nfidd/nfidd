# nfidd 1.3.1

- removed an unused `init_r` argument from the renewal model (#652)
- clarified the joint nowcasting session (#659)
- updated the return link to point to the forecasting concepts session (#656)
- renamed the mpox figure and credited its sources on the nowcasting slides (#665)

# nfidd 1.3.0

- restructured the course to start with delay distributions, moving the probability and Stan introduction to reference and self-study material (#621)
- dropped the unused `gen_time_pmf` argument from `simulate_onsets()` (#607)
- replaced superseded `transmute()` with `mutate()` + `select()` (#606)
- used `N` for the sample size in `lognormal.stan` to match `gamma.stan` (#605)
- used the `quantile_level` column for the QRA weights filter (#603)
- added a Stan model index reference page (#612)
- enabled site search (#614)
- added a real-time Rt exercise and callout to the renewal session (#615)
- plotted the forecast reproduction number over the forecast horizon (#639)
- added an optional dropdown on baselines to the forecasting concepts session (#641)
- added missing ensemble forecasting citations and cited Bracher et al. 2021 for over/underprediction (#648, #604)
- marked optional content consistently across the sessions and the timetable (#623, #625)
- updated learning outcomes to match course content (#611)
- corrected an overstated bias claim for ad-hoc censoring fixes (#634)
- highlighted printed Stan models in rendered output (#643)
- fixed broken LaTeX in the CRPS formula (#642)

# nfidd 1.2.0

- made `add_delays()` more flexible with configurable delay distributions and hospitalisation probability (#584)
- added `save_warmup` argument to `nfidd_sample()` (#584)
- fixed Stan function extraction regex to handle `array[]` return types (#584)
- fixed forecasting model to generate forecast random walk in generated quantities rather than extending estimated parameters (#585)
- allowed zero-day delays in censored delay model (#585)
- added forecasting to the joint nowcasting with R model (#585)
- improved priors in joint nowcasting models (#585)
- added Stan reference documentation pages (#586)
- updated session content with improvements from SISMID (#587)

# nfidd 1.1.2

- added the R version of `condition_onsets_by_report()`

# nfidd 1.1.1

- adapted `nfidd_cmdstan_model()` to work with an include path option, and a model file name argument

# nfidd 1.1.0

- fixed a bug in convolution function which affected the earliest part of convoluted time series #475.
- renamed `target_day` to `origin_day` for clarity #465
- added `nffid_sample()` function to speed up default inference #457
- replaced `vapply` with for loop in `convolve_with_delay` for clarity #433
- streamlined the use of logged and natural R #424
- added the `summarise_lognormal()` function for mean/sd summarises #406

# nfidd 1.0.0

In development version of the package and teaching material for teaching in Bangkok in November 2024.

This included a complete redevelopment of the package where what previously were snippets are now functions.

# nfidd 0.1.0

Initial release of the `nfidd` package and teaching material for teaching in June 2024 in Stockholm.
