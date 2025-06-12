test_that("start_telemetry_logging creates log directory and log file after first log entry", { # nolint line_length_linter
  temp_log_dir <- tempfile("telemetry_logs_")

  log_file <- suppressMessages(start_telemetry_logging(log_dir = temp_log_dir))

  expect_true(dir.exists(temp_log_dir))

  expect_false(file.exists(log_file)) # Should NOT exist yet

  logger::log_info("Test log entry",
    namespace = get(".telemetry_ns", envir = asNamespace("impact.telemetry"))
  )

  expect_true(file.exists(log_file))

  expect_match(basename(log_file), "^telemetry-[0-9]+\\.log$")

  expect_true(
    get(".pkg_env", envir = asNamespace("impact.telemetry"))$is_initialized
  )

  log_contents <- readLines(log_file)
  expect_true(length(log_contents) > 0)

  unlink(temp_log_dir, recursive = TRUE)
})

test_that("start_telemetry_logging uses mocked R user data folder", {
  temp_log_dir <- tempfile("mocked_user_data_dir_")
  dir.create(temp_log_dir)

  mockr::with_mock(
    `get_user_data_dir` = function(package = "impact.telemetry") {
      expect_equal(package, "impact.telemetry")
      temp_log_dir
    },
    {
      log_file <- suppressMessages(start_telemetry_logging(log_dir = NULL))

      expect_true(dir.exists(temp_log_dir))
      expect_true(
        startsWith(
          normalizePath(dirname(log_file)),
          normalizePath(temp_log_dir)
        )
      )

      expect_false(file.exists(log_file))

      logger::log_info(
        "Test log entry (mocked user dir)",
        namespace = get(".telemetry_ns",
          envir = asNamespace("impact.telemetry")
        )
      )
      expect_true(file.exists(log_file))

      log_contents <- readLines(log_file)
      expect_true(length(log_contents) > 0)
    }
  )

  unlink(temp_log_dir, recursive = TRUE)
})
