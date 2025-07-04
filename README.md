
# Nowcasting and forecasting infectious disease dynamics

This repository contains the material to create the nfidd course page.

All the raw material is in the folder `sessions/` and is written in
`quarto`. Any changes to the quarto files are automatically updated on
the web site once committed to the `main` branch.

To add a lesson, add a `.qmd` file in the `sessions` folder with a YAML
field `order:` corresponding to where it fits in, and edit
`sessions.qmd` to add it to the schedule.

## Local testing

The `html` pages can be generated locally using the function

``` r
quarto::quarto_render()
```

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

All contributions to this project are gratefully acknowledged using the
[`allcontributors` package](https://github.com/ropensci/allcontributors)
following the [all-contributors](https://allcontributors.org)
specification. Contributions of any kind are welcome!

### Code

<a href="https://github.com/nfidd/sismid/commits?author=sbfnk">sbfnk</a>,
<a href="https://github.com/nfidd/sismid/commits?author=seabbs">seabbs</a>,
<a href="https://github.com/nfidd/sismid/commits?author=kathsherratt">kathsherratt</a>,
<a href="https://github.com/nfidd/sismid/commits?author=nickreich">nickreich</a>,
<a href="https://github.com/nfidd/sismid/commits?author=github-actions[bot]">github-actions\[bot\]</a>,
<a href="https://github.com/nfidd/sismid/commits?author=dependabot[bot]">dependabot\[bot\]</a>,
<a href="https://github.com/nfidd/sismid/commits?author=jamesmbaazam">jamesmbaazam</a>,
<a href="https://github.com/nfidd/sismid/commits?author=ManuelStapper">ManuelStapper</a>,
<a href="https://github.com/nfidd/sismid/commits?author=zsusswein">zsusswein</a>

### Issues

<a href="https://github.com/nfidd/sismid/issues?q=is%3Aissue+author%3Atrobacker">trobacker</a>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
