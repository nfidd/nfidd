#' Get the path to Stan code
#'
#' @return A character string with the path to the Stan code
#'
#' @family stantools
#'
#' @export
nfidd_stan_path <- function() {
  system.file("stan", package = "nfidd")
}

#' Count the number of unmatched braces in a line
#' @noRd
.unmatched_braces <- function(line) {
  ifelse(
    grepl("{", line, fixed = TRUE),
    length(gregexpr("{", line, fixed = TRUE)), 0
  ) -
    ifelse(
      grepl("}", line, fixed = TRUE),
      length(gregexpr("}", line, fixed = TRUE)), 0
    )
}

#' Extract function names or content from Stan code
#'
#' @param content Character vector containing Stan code
#'
#' @param names_only Logical, if TRUE extract function names, otherwise
#'  extract function content.
#'
#' @param functions Optional, character vector of function names to extract
#'   content for.
#'
#' @return Character vector of function names or content
#'
#' @keywords internal
.extract_stan_functions <- function(
    content,
    names_only = FALSE,
    functions = NULL) {
  def_pattern <- "^(array\\[\\]\\s*)?(real|int|void|vector|row_vector|matrix)\\s+"
  func_pattern <- paste0(
    def_pattern,
    "(\\w+)\\s*\\("
  )
  func_lines <- grep(func_pattern, content, value = TRUE)
  # remove the func_pattern
  func_lines <- sub(def_pattern, "", func_lines)
  # get the next complete word after the pattern until the first (
  func_names <- sub("\\s*\\(.*$", "", func_lines)
  if (!is.null(functions)) {
    func_names <- intersect(func_names, functions)
  }
  if (names_only) {
    return(func_names)
  } else {
    func_content <- character(0)
    for (func_name in func_names) {
      start_line <- grep(paste0(def_pattern, func_name, "\\s*\\("), content)
      if (length(start_line) == 0) next
      end_line <- start_line
      brace_count <- 0
      # Ensure we find the first opening brace
      # Find first opening brace
      repeat {
        brace_count <- brace_count + .unmatched_braces(content[end_line])
        end_line <- end_line + 1
        if (brace_count > 0) break
      }

      # Continue until all braces are closed
      repeat {
        brace_count <- brace_count + .unmatched_braces(content[end_line])
        if (brace_count == 0) break
        end_line <- end_line + 1
      }

      func_content <- c(
        func_content,
        paste(content[start_line:end_line], collapse = "\n")
      )
    }
    return(func_content)
  }
}

#' Get Stan function names from Stan files
#'
#' This function reads all Stan files in the specified directory and extracts
#' the names of all functions defined in those files.
#'
#' @param stan_path Character string specifying the path to the directory
#' containing Stan files. Defaults to the Stan path of the nfidd
#' package.
#'
#' @return A character vector containing unique names of all functions found in
#' the Stan files.
#'
#' @export
#'
#' @family stantools
nfidd_stan_functions <- function(
    stan_path = nfidd::nfidd_stan_path()) {
  stan_files <- list.files(
    file.path(stan_path, "functions"),
    pattern = "\\.stan$", full.names = TRUE,
    recursive = TRUE
  )
  functions <- character(0)
  for (file in stan_files) {
    content <- readLines(file)
    functions <- c(
      functions, .extract_stan_functions(content, names_only = TRUE)
    )
  }
  unique(functions)
}

#' Get Stan files containing specified functions
#'
#' This function retrieves Stan files from a specified directory, optionally
#' filtering for files that contain specific functions.
#'
#' @param functions Character vector of function names to search for. If NULL,
#'   all Stan files are returned.
#' @inheritParams nfidd_stan_functions
#'
#' @return A character vector of file paths to Stan files.
#'
#' @export
#'
#' @family stantools
nfidd_stan_function_files <- function(
    functions = NULL,
    stan_path = nfidd::nfidd_stan_path()) {
  # List all Stan files in the directory
  all_files <- list.files(
    file.path(stan_path, "functions"),
    pattern = "\\.stan$",
    full.names = TRUE,
    recursive = TRUE
  )

  if (is.null(functions)) {
    return(all_files)
  } else {
    # Initialize an empty vector to store matching files
    matching_files <- character(0)

    for (file in all_files) {
      content <- readLines(file)
      extracted_functions <- .extract_stan_functions(content, names_only = TRUE)

      if (any(functions %in% extracted_functions)) {
        matching_files <- c(matching_files, file)
      }
    }

    # remove the path from the file names
    matching_files <- sub(
      paste0(stan_path, "/"), "", matching_files
    )
    return(matching_files)
  }
}

#' Load Stan functions as a string
#'
#' @param functions Character vector of function names to load. Defaults to all
#' functions.
#'
#' @param stan_path Character string, the path to the Stan code. Defaults to the
#' path to the Stan code in the nfidd package.
#'
#' @param wrap_in_block Logical, whether to wrap the functions in a
#' `functions{}` block. Default is FALSE.
#'
#' @param write_to_file Logical, whether to write the output to a file. Default
#' is FALSE.
#'
#' @param output_file Character string, the path to write the output file if
#' write_to_file is TRUE. Defaults to "nfidd_functions.stan".
#'
#' @return A character string containing the requested Stan functions
#'
#' @family stantools
#'
#' @export
nfidd_load_stan_functions <- function(
    functions = NULL, stan_path = nfidd::nfidd_stan_path(),
    wrap_in_block = FALSE, write_to_file = FALSE,
    output_file = "nfidd_functions.stan") {
  stan_files <- list.files(
    file.path(stan_path, "functions"),
    pattern = "\\.stan$", full.names = TRUE,
    recursive = TRUE
  )
  all_content <- character(0)

  for (file in stan_files) {
    content <- readLines(file)
    if (is.null(functions)) {
      all_content <- c(all_content, content)
    } else {
      for (func in functions) {
        func_content <- .extract_stan_functions(
          content,
          names_only = FALSE,
          functions = func
        )
        all_content <- c(all_content, func_content)
      }
    }
  }

  # Add version comment
  version_comment <- paste(
    "// Stan functions from nfidd version",
    utils::packageVersion("nfidd")
  )
  all_content <- c(version_comment, all_content)

  if (wrap_in_block) {
    all_content <- c("functions {", all_content, "}")
  }

  result <- paste(all_content, collapse = "\n")

  if (write_to_file) {
    writeLines(result, output_file)
    message("Stan functions written to: ", output_file, "\n")
  }

  return(result)
}

#' List Available Stan Models in NFIDD
#'
#' This function finds all available Stan models in the NFIDD package and
#' returns their names without the .stan extension.
#'
#' @param stan_path Character string specifying the path to Stan files. Defaults
#'   to the result of `nfidd_stan_path()`.
#'
#' @return A character vector of available Stan model names.
#'
#' @export
#'
#' @examples
#' nfidd_stan_models()
nfidd_stan_models <- function(stan_path = nfidd::nfidd_stan_path()) {
  stan_files <- list.files(
    stan_path,
    pattern = "\\.stan$", full.names = FALSE,
    recursive = FALSE
  )

  # Remove .stan extension
  model_names <- tools::file_path_sans_ext(stan_files)

  return(model_names)
}

#' Create a CmdStanModel with NFIDD Stan functions
#'
#' This function creates a CmdStanModel object using either a specified Stan
#' model from the NFIDD package or a custom Stan file provided by the user.
#'
#' @param model_name Character string specifying which Stan model to use from
#'   the NFIDD package. Ignored if model_file is provided.
#' @param model_file Character string specifying the path to a custom Stan file.
#'   If provided, this takes precedence over model_name.
#' @param include_paths Character vector of paths to include for Stan
#'   compilation. Defaults to the result of `nfidd_stan_path()` or can be
#'   overridden using the R option "nfidd.stan_path".
#' @param ... Additional arguments passed to cmdstanr::cmdstan_model().
#'
#' @return A CmdStanModel object.
#'
#' @export
#'
#' @family modelhelpers
#'
#' @importFrom cmdstanr cmdstan_model
#'
#' @examplesIf requireNamespace("cmdstanr", quietly = TRUE)
#' if (!is.null(cmdstanr::cmdstan_version(error_on_NA = FALSE))) {
#'   # Using a model from the NFIDD package
#'   model <- nfidd_cmdstan_model("simple-nowcast", compile = FALSE)
#'   model
#'
#' }
nfidd_cmdstan_model <- function(
    model_name = NULL,
    model_file = NULL,
    include_paths = getOption("nfidd.stan_path", nfidd::nfidd_stan_path()),
    ...) {

  # Determine which Stan file to use
  if (!is.null(model_file)) {
    # Use custom model file
    if (!file.exists(model_file)) {
      stop(sprintf("Custom model file '%s' not found", model_file))
    }
    stan_model <- model_file
  } else if (!is.null(model_name)) {
    # Use model from NFIDD package
    stan_model <- system.file(
      "stan", paste0(model_name, ".stan"),
      package = "nfidd"
    )

    if (stan_model == "") {
      stop(sprintf("Model '%s.stan' not found in NFIDD package", model_name))
    }
  } else {
    stop("Either model_name or model_file must be provided")
  }

  cmdstan_model(
    stan_model,
    include_paths = include_paths,
    ...
  )
}

#' Sample from a CmdStanModel with NFIDD course defaults
#'
#' This function wraps the cmdstanr sample method with optimized defaults
#' for course use to speed up model fitting. All cmdstanr sample arguments
#' can still be overridden for experimentation.
#'
#' @param model A CmdStanModel object to sample from.
#' @param iter_warmup Integer, number of warmup iterations per chain.
#'   Defaults to 500 (reduced from cmdstanr default of 1000) for course speed.
#' @param iter_sampling Integer, number of sampling iterations per chain.
#'   Defaults to 500 (reduced from cmdstanr default of 1000) for course speed.
#' @param parallel_chains Integer, number of chains to run in parallel.
#'   Defaults to 4 for course speed.
#' @param save_warmup Logical, whether to save warmup samples.
#'   Defaults to FALSE for course speed.
#' @param ... Additional arguments passed to the model's sample method.
#'   All cmdstanr sample arguments are supported.
#'
#' @return A CmdStanMCMC object containing the posterior samples.
#'
#' @export
#'
#' @family modelhelpers
nfidd_sample <- function(model,
                         iter_warmup = 500,
                         iter_sampling = 500,
                         parallel_chains = 4,
                         save_warmup = FALSE,
                         ...) {
  model$sample(
    iter_warmup = iter_warmup,
    iter_sampling = iter_sampling,
    parallel_chains = parallel_chains,
    save_warmup = save_warmup,
    ...
  )
}
