.expect_snapshot <- purrr::partial(
  testthat::expect_snapshot,
  transform = function(lines) {
    lines |>
      # Remove lines that indicate progress
      stringr::str_subset("^[\\|/\\-\\\\] \\|", negate = TRUE) |>
      # Remove empty lines
      stringr::str_subset("^$", negate = TRUE) |>
      # Remove test timing information
      stringr::str_remove_all("\\s\\[\\d+.\\d+s\\]") |>
      # Remove test run duration
      stringr::str_remove_all("Duration:\\s\\d+.\\d+\\ss") |>
      stringr::str_trim()
  },
  variant = variant()
)

.with_example_dir <- function(path, code) {
  withr::with_dir(
    system.file("examples", path, package = "shinytest3"),
    code
  )
}

test_example <- function(path, tests_path = "tests/acceptance", ...) {
  .with_example_dir(path, {
    .expect_snapshot(
      testthat::test_dir(
        tests_path,
        reporter = testthat::ProgressReporter$new(show_praise = FALSE),
        stop_on_failure = FALSE,
        ...
      )
    )
  })
}

test_that("verify_output", {
  skip_if(is_checking())
  test_example("verify_output")
})
