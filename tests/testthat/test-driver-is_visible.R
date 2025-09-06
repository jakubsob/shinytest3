describe("driver$is_visible", {
  it("should return FALSE if element is not visible", {
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
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$is_visible("Run")

    expect_false(result)
  })

  it("should return TRUE if element is visible", {
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
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$is_visible("Run")

    expect_true(result)
  })
})
