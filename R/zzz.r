.onLoad <- function(libname, pkgname) {
  # Register the knit_print method for CmdStanModel dynamically so we do not
  # need to take a hard dependency on knitr. During rendering knitr is always
  # loaded before package chunks run, so the method is in place when needed.
  if (requireNamespace("knitr", quietly = TRUE)) {
    registerS3method(
      "knit_print", "CmdStanModel", knit_print.CmdStanModel,
      envir = asNamespace("knitr")
    )
  }
  invisible()
}
