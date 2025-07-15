## GitHub Issues

### Issue #77: Consider a facet or intervals for nowcasting/joint
- **Author**: seabbs (Sam Abbott)
- **Status**: OPEN
- **Created**: 2025-07-12T14:26:50Z
- **Updated**: 2025-07-12T14:26:52Z

**Description**:
I can't really distinguish the overlap/spread of the green/blue lines in particular. Maybe facet? or use sample-derived intervals?

_Originally posted by @nickreich in https://github.com/nfidd/sismid/pull/70#discussion_r2201336539_

Definitely not intervals so consider a facet.

### Issue #76: Check horizons for nowcast/forecast session
- **Author**: seabbs (Sam Abbott)
- **Status**: OPEN
- **Created**: 2025-07-12T14:26:03Z
- **Updated**: 2025-07-15T08:56:27Z

**Description**:
``` 
Warning: Some forecasts have different numbers of rows (e.g. quantiles or samples).
scoringutils found: 98, 80. This may be a problem (it can potentially distort
scores, making it more difficult to compare them), so make sure this is
intended.
```

Does this mean that some models had more forecast horizons than others? if so, maybe consider aligning them so it's the same?

_Originally posted by @nickreich in https://github.com/nfidd/sismid/pull/70#discussion_r2201340816_

**Comments**:
- **seabbs** (2025-07-15T08:56:27Z): I think this was for the nowcasting and forecasting session so reopening

### Issue #81: Check stan model input and output
- **Author**: seabbs (Sam Abbott)
- **Status**: OPEN
- **Created**: 2025-07-12T14:47:47Z
- **Updated**: 2025-07-14T15:27:08Z

**Description**:
This chunk prints out many many exceptions. It's annoying to scroll through...

_Originally posted by @nickreich in https://github.com/nfidd/sismid/pull/70#discussion_r2201131317_

And provide another callout (see earlier sessions) about the diagnostics that stan returns and why this is useful (as it can be off-putting for users used to silent black box approaches).

---

## Investigation Findings and Suggestions

### Issue #77: Consider a facet or intervals for nowcasting/joint

**Location**: `/sessions/forecasting-nowcasting.qmd`, lines 230-261

**Problem**: The plot uses overlapping red, green, and black lines that are difficult to distinguish, especially for colour-blind users.

**Recommended Solution - Faceting**:
```r
# Prepare data for faceting
combined_data <- bind_rows(
  complete_at_horizon |> 
    mutate(dataset = "Complete data", value = complete_onsets),
  available_onsets |> 
    mutate(dataset = "Available now", value = available_onsets),
  complete_data |> 
    mutate(dataset = "Complete as of now", value = available_onsets)
) |>
  mutate(dataset = factor(dataset, 
                          levels = c("Complete data", "Available now", "Complete as of now")))

# Create faceted plot
ggplot(combined_data, aes(x = day, y = value)) +
  geom_line(linewidth = 1) +
  facet_wrap(~ dataset, ncol = 1, scales = "free_y") +
  geom_vline(xintercept = cutoff, linetype = "dotted") +
  geom_vline(xintercept = cutoff - complete_threshold, 
             linetype = "dotted", alpha = 0.5) +
  labs(x = "Day", y = "Onsets", title = "Different views of the data") +
  theme_minimal()
```

**Alternative - Improved Colours and Line Types**:
```r
ggplot() +
  geom_line(data = complete_at_horizon, 
            aes(x = day, y = complete_onsets, colour = "Complete data", linetype = "Complete data"), 
            linewidth = 1) +
  geom_line(data = available_onsets, 
            aes(x = day, y = available_onsets, colour = "Available now", linetype = "Available now"), 
            linewidth = 1) +
  geom_line(data = complete_data, 
            aes(x = day, y = available_onsets, colour = "Complete as of now", linetype = "Complete as of now"), 
            linewidth = 1.2) +
  scale_colour_manual(
    values = c(
      "Complete data" = "#000000",      # Black
      "Available now" = "#E69F00",      # Orange (colour-blind safe)
      "Complete as of now" = "#0072B2"  # Blue (colour-blind safe)
    )
  ) +
  scale_linetype_manual(
    values = c(
      "Complete data" = "solid",
      "Available now" = "dashed",
      "Complete as of now" = "dotted"
    )
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
```

### Issue #76: Check horizons for nowcast/forecast session

**Locations**: 
- `/sessions/forecasting-nowcasting.qmd`, lines 324-364 (ensemble generation)
- Lines 385-395 (score calculation)

**Root Cause**: The ensemble approaches are generating different numbers of samples:
- Direct approach: 98 rows (should be 100)
- Mean approach: 80 rows (should be 100)

**Solution**:
```r
# Fix the direct approach ensemble generation (line 332)
direct_ensemble <- direct_fit |>
  tidybayes::gather_draws(nowcast[day]) |>
  ungroup() |>
  filter(day >= cutoff - complete_threshold) |>
  left_join(dates, by = "day") |>
  select(date, .draw, prediction = .value) |>
  distinct()  # Add this to ensure unique samples

# Fix the mean approach ensemble generation (line 352)
mean_ensemble <- mean_fit |>
  tidybayes::gather_draws(nowcast[day]) |>
  ungroup() |>
  filter(day >= cutoff - complete_threshold) |>
  left_join(dates, by = "day") |>
  select(date, .draw, prediction = .value) |>
  distinct()  # Add this to ensure unique samples

# Add validation after ensemble creation (new chunk after line 364)
ensemble_rows <- combined_ensemble |>
  group_by(approach) |>
  summarise(
    n_rows = n(),
    n_dates = n_distinct(date),
    n_draws = n_distinct(.draw),
    expected_rows = n_dates * n_draws
  )
print(ensemble_rows)
```

### Issue #81: Check stan model input and output

**Affected Files**:
- `/sessions/nowcasting.qmd` (lines 244-246, 334-336, 408-410)
- `/sessions/joint-nowcasting.qmd` (lines 122-124, 209-211)
- `/sessions/R-estimation-and-the-renewal-equation.qmd` (lines 247-249, 329-331, 393-395)
- `/sessions/using-delay-distributions-to-model-the-data-generating-process-of-an-epidemic.qmd` (lines 440-442)
- `/sessions/forecasting-nowcasting.qmd` (multiple locations)

**Solution 1 - Add Callout** (place before first Stan output in each session):
```markdown
::: {.callout-tip}
## Understanding Stan Model Output

When we display Stan model fits, you'll see diagnostic information that may look like warnings or errors. This is normal and valuable! Stan's diagnostics help ensure our results are reliable by checking:

- **Convergence**: Whether different chains agree (Rhat should be < 1.01)
- **Sampling efficiency**: Whether we have enough effective samples (ESS)
- **Geometry issues**: Divergences and treedepth warnings indicate difficult posterior geometries

These diagnostics are features, not bugs! They help us identify when we need to:
- Run longer chains
- Adjust sampling parameters (like `adapt_delta`)
- Rethink our model parameterisation

For a detailed explanation of these diagnostics, see the [Stan reference guide](../reference/stan#common-issues--solutions).
:::
```

**Solution 2 - Suppress Verbose Output**:
Replace direct fit displays with:
```r
```{r, echo=FALSE, warning=FALSE}
# Show only key parameters summary
simple_nowcast_fit$summary(variables = c("nowcast", "log_R"))
```

Or for visual inspection without full diagnostics:
```r
```{r, results='hide'}
simple_nowcast_fit  # Full output hidden
```
```{r}
# Show selected diagnostics
cat("Sampling complete. Max Rhat:", 
    max(simple_nowcast_fit$summary()$rhat, na.rm = TRUE), "\n")
```