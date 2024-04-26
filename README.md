
# Nowcasting and forecasting infectious disease dynamics

This repository contains the material to create the nfiidd course page.

All the raw material is in the folder `Rmd/` and is written in
`Rmarkdown`. Any changes to the Rmarkdown files are automatically
updated on the web site once committed to the `main` branch.

To add a lesson, add an Rmd file in `Rmd/` and edit `Rmd/_site.yml` so
it appears in the menu.

## Local testing

The `html` pages can be generated locally using the function

``` r
rmarkdown::render_site("Rmd/")
```

This creates the `html` pages in the `Rmd/_site` directory.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

All contributions to this project are gratefully acknowledged using the
[`allcontributors`
package](https://github.com/ropenscilabs/allcontributors) following the
[all-contributors](https://allcontributors.org) specification.
Contributions of any kind are welcome!

<a href="https://github.com/nfidd/nfidd/commits?author=sbfnk">sbfnk</a>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->
