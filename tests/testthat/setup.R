chromote::local_chrome_version(134, binary = "chrome")

options(
  shinytest2.load_timeout = 30 * 1000,
  shinytest2.timeout = 10 * 1000
)

variant <- function() {
  ifelse(testthat::is_checking(), "check", "local")
}

expect_snapshot_error <- purrr::partial(
  testthat::expect_snapshot_error,
  variant = variant()
)
