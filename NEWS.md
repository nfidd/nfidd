# nfidd (development version)

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
