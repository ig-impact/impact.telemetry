#' @noRd
get_user_data_dir <- function(package = "impact.telemetry") {
  tools::R_user_dir(package, "data")
}
