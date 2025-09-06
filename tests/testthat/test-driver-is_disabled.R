describe("driver$is_disabled", {
  it("should return TRUE if element is disabled", {
    # Arrange
    make_app <- function() {
      button <- function(id, label = NULL, choices, ..., testid) {
        shiny::actionButton(
          inputId = id,
          label = label,
          ...
        ) |>
          testable_component(
            id = id,
            testid = testid,
            testtype = "button"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          button(
            id = "test-button",
            label = "Run",
            testid = "Run",
            disabled = TRUE
          )
        ),
        server = function(input, output) {}
      )
    }
    d <- Driver$new(make_app())

    # Act
    result <- d$is_disabled("Run")

    expect_true(result)

    # Teardown
    d$stop()
  })

  it("should return FALSE if element is not disabled", {
    # Arrange
    make_app <- function() {
      button <- function(id, label = NULL, choices, ..., testid) {
        shiny::actionButton(
          inputId = id,
          label = label,
          ...
        ) |>
          testable_component(
            id = id,
            testid = testid,
            testtype = "button"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          button(
            id = "test-button",
            label = "Run",
            testid = "Run"
          )
        ),
        server = function(input, output) {}
      )
    }
    d <- Driver$new(make_app())

    # Act
    result <- d$is_disabled("Run")

    expect_false(result)

    # Teardown
    d$stop()
  })
})
