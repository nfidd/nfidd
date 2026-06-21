#' Print a Stan model as a highlighted code block when knitting
#'
#' A \code{\link[knitr]{knit_print}} method for \code{CmdStanModel} objects.
#' When a model loaded with \code{\link{nfidd_cmdstan_model}} is printed in a
#' Quarto or R Markdown chunk, the Stan code is rendered as a syntax-highlighted,
#' line-numbered code block instead of plain monospaced output.
#'
#' The method is registered dynamically when the package is loaded (see the
#' \code{.onLoad} hook), so existing chunks that print a model object pick it up
#' without any change to the source documents. It only affects knitting:
#' printing a model at an interactive console still uses the default
#' \code{cmdstanr} print method.
#'
#' @param x A \code{CmdStanModel} object, as returned by
#'   \code{\link{nfidd_cmdstan_model}}.
#' @param ... Additional arguments passed to methods (ignored).
#'
#' @return A \code{\link[knitr]{asis_output}} object containing a fenced
#'   \code{stan} code block with line numbers.
#'
#' @keywords internal
knit_print.CmdStanModel <- function(x, ...) {
  knitr::asis_output(
    paste(c("```{.stan .numberLines}", x$code(), "```"), collapse = "\n")
  )
}
