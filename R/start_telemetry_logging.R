#' A logger layout that only returns the raw message, with no metadata.
#' @noRd
layout_passthrough <- function(level, msg, ...) {
  msg
}

#' A logger formatter that evaluates the message expression verbatim.
#' This bypasses the default 'glue' formatter, preventing errors with JSON.
#' @noRd
formatter_verbatim <- function(expr, ...) {
  eval(expr, envir = parent.frame(2))
}

#' Internal helper for providing a default value for NULL.
#' @noRd
`%||%` <- function(a, b) if (is.null(a)) b else a

#' Initialize the Telemetry Logging System
#'
#' Sets up a dedicated, namespaced logger that writes structured JSON logs to a
#' file. This configuration is isolated and does not interfere with the global
#' logger or configurations from other packages. This function should typically
#' be called once per session.
#'
#' @param log_dir The directory where log files will be stored. If `NULL`
#'   (the default), a standard, operating-system-specific user data directory
#'   is used, managed by `tools::R_user_dir`.
#' @param threshold The minimum log level to record (e.g., `logger::INFO`,
#'   `logger::WARN`). Defaults to `INFO`.
#' @return Invisibly returns the full path to the log file being used for the
#'   current session.
#' @export
#' @examples
#' \dontrun{
#' # Initialize logging to the default directory
#' start_telemetry_logging()
#'
#' # Initialize logging to a custom directory
#' start_telemetry_logging(log_dir = tempdir())
#' }
start_telemetry_logging <- function(log_dir = NULL, threshold = logger::INFO) {
  # --- 1. Define Log Directory and File ---
  if (is.null(log_dir)) {
    # Use a standard, user-specific data directory for persistence
    log_dir <- tools::R_user_dir("impact.telemetry", "data")
  }

  # Ensure the directory exists
  if (!dir.exists(log_dir)) {
    dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # Create a unique log file for each R process
  log_file <- file.path(log_dir, sprintf("telemetry-%s.log", Sys.getpid()))

  # --- 2. Configure the namespaced logger ---
  # This configuration ONLY applies to the ".telemetry_ns" namespace
  logger::log_formatter(formatter_verbatim, namespace = .telemetry_ns)
  logger::log_layout(layout_passthrough, namespace = .telemetry_ns)
  logger::log_threshold(threshold, namespace = .telemetry_ns)
  logger::log_appender(logger::appender_file(log_file), namespace = .telemetry_ns)

  # --- 3. Provide feedback to the user ---
  message("Telemetry logging started. Log file: ", basename(log_file))
  invisible(log_file)
}
