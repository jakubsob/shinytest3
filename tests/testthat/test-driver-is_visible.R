test_that("driver$is_visible should return FALSE if element is not visible", {
  # Arrange
  make_app <- function() {
    button <- function(id, label = NULL, ..., testid) {
      shiny::actionButton(inputId = id, label = label, ...) |>
        testable_component(
          id = id,
          testid = testid,
          testtype = "button"
        )
    }

    shiny::shinyApp(
      ui = bslib::page_fluid(
        theme = bslib::bs_theme(version = 5),
        shiny::div(
          class = "d-none",
          button(
            id = "test-Run",
            label = "Run",
            testid = "Run"
          )
        )
      ),
      server = function(input, output) {}
    )
  }
  driver5 <- Driver$new(make_app())

  # Act
  result <- driver5$is_visible("Run")

  # Assert
  expect_false(result)

  # Teardown
  driver5$stop()
})

test_that("driver$is_visible should return TRUE if element is visible", {
  # Arrange
  make_app <- function() {
    button <- function(id, label = NULL, ..., testid) {
      shiny::actionButton(inputId = id, label = label, ...) |>
        testable_component(
          id = id,
          testid = testid,
          testtype = "button"
        )
    }

    shiny::shinyApp(
      ui = bslib::page_fluid(
        theme = bslib::bs_theme(version = 5),
        shiny::div(
          button(
            id = "test-Run",
            label = "Run",
            testid = "Run"
          )
        )
      ),
      server = function(input, output) {}
    )
  }
  driver5 <- Driver$new(make_app())

  # Act
  result <- driver5$is_visible("Run")

  # Assert
  expect_true(result)

  # Teardown
  driver5$stop()
})
