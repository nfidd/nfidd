% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nfidd-stan-tools.r
\name{nfidd_stan_function_files}
\alias{nfidd_stan_function_files}
\title{Get Stan files containing specified functions}
\usage{
nfidd_stan_function_files(
  functions = NULL,
  stan_path = nfidd::nfidd_stan_path()
)
}
\arguments{
\item{functions}{Character vector of function names to search for. If NULL,
all Stan files are returned.}

\item{stan_path}{Character string specifying the path to the directory
containing Stan files. Defaults to the Stan path of the nfidd
package.}
}
\value{
A character vector of file paths to Stan files.
}
\description{
This function retrieves Stan files from a specified directory, optionally
filtering for files that contain specific functions.
}
\seealso{
Other stantools: 
\code{\link{nfidd_load_stan_functions}()},
\code{\link{nfidd_stan_functions}()},
\code{\link{nfidd_stan_path}()}
}
\concept{stantools}
