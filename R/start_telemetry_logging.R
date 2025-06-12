#' @importFrom cli cli_alert_success
#' @importFrom tools R_user_dir
#' @importFrom logger INFO log_layout appender_file log_threshold log_appender
#' @importFrom logger layout_json
NULL

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
  if (is.null(log_dir)) {
    log_dir <- get_user_data_dir()
  }

  if (!dir.exists(log_dir)) {
    dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
  }

  log_file <- file.path(log_dir, sprintf("telemetry-%s.log", Sys.getpid()))

  # Use the logger's built-in JSON layout instead of custom formatters.
  logger::log_layout(logger::layout_json(), namespace = .telemetry_ns)
  logger::log_threshold(threshold, namespace = .telemetry_ns)
  logger::log_appender(
    logger::appender_file(log_file),
    namespace = .telemetry_ns
  )

  .pkg_env$is_initialized <- TRUE

  # Use cli for more structured and aesthetically pleasing console messages.
  cli::cli_alert_success("Telemetry logging started. Log file: {.path {basename(log_file)}}")

  invisible(log_file)
}
