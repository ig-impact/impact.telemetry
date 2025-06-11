#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL


#' The internal, private namespace used by this package for all logging.
#' @noRd
.telemetry_ns <- "impact.telemetry"

#' The private environment used to store package state, such as whether
#' the logger has been initialized.
#' @noRd
.pkg_env <- new.env(parent = emptyenv())
.pkg_env$is_initialized <- FALSE
