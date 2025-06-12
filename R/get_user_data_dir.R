#' @noRd
get_user_data_dir <- function(package = "impact.telemetry") {
  env_override <- Sys.getenv("IMPACT_TELEMETRY_USER_DIR", unset = NA_character_)
  if (!is.na(env_override)) {
    return(env_override)
  }
  tools::R_user_dir(package, "data")
}
