#' Wrap a Function to Add Telemetry Logging
#'
#' A higher-order function that takes a target function and returns a new
#' version of that function. When the new function is called, it executes the
#' original function and logs a structured telemetry event describing the call's
#' context and outcome.
#'
#' The logged event includes a timestamp, status (success/error), duration,
#' and optional arguments and return values. All log messages are directed to
#' the private `impact.telemetry` namespace and will only be recorded if
#' `start_telemetry_logging()` has been called.
#'
#' @param f The function to wrap with telemetry logging.
#' @param event_name A character string providing a human-readable name for the
#'   event being logged. If `NULL` (the default), the name of the function `f`
#'   is used.
#' @param log_args A boolean flag. If `TRUE`, the function's arguments are
#'   captured in the log entry. This is a primary control for privacy and
#'   verbosity.
#' @param log_result A boolean flag. If `TRUE`, the function's return value is
#'   captured in the log entry. This should be used with caution for functions
#'   that return large objects or sensitive data.
#' @return A new function that is a version of `f` with telemetry enabled.
#' @export
#' @examples
#' start_telemetry_logging() # Initialize logging before using this function
#'
#' # Define a function
#' calculate_sum <- function(a, b) a + b
#'
#' # Create an instrumented version
#' logged_sum <- with_telemetry(calculate_sum, event_name = "sum_calculation")
#'
#' # Calling this function will now generate a log entry
#' result <- logged_sum(10, 20)
with_telemetry <- function(f,
                           event_name = NULL,
                           log_args = TRUE,
                           log_result = FALSE) {
  event <- event_name %||% deparse(substitute(f))

  function(...) {
    payload <- list(
      timestamp = Sys.time(),
      event = event,
      status = "success"
    )

    if (log_args) {
      payload$args <- list(...)
    }

    start_time <- Sys.time()

    tryCatch(
      {
        res <- f(...) # Call the original function

        duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
        payload$duration_ms <- round(duration, 3)

        if (log_result) {
          payload$result <- res
        }

        json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE)
        logger::log_info(
          json_payload,
          namespace = .telemetry_ns
        )

        return(res)
      },
      error = function(e) {
        # --- ERROR PATH ---
        duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
        payload$status <- "error"
        payload$error <- e$message
        payload$duration_ms <- round(duration, 3)

        json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE)
        # Direct log to the private namespace, skipping the formatter
        logger::log_error(
          json_payload,
          namespace = .telemetry_ns
        )

        stop(e) # Re-throw original error
      }
    )
  }
}

lf
# [1] "/home/ig/.local/share/R/impact.telemetry/telemetry-44525.log"
