chromote::local_chrome_version(134, binary = "chrome")

variant <- function() {
  ifelse(testthat::is_checking(), "check", "local")
}

expect_snapshot_error <- purrr::partial(
  testthat::expect_snapshot_error,
  variant = variant()
)
