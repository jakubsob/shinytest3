describe("driver$is_visible", {
  it("should return FALSE if element is not visible", {
    # Arrange
    make_app <- function() {
      dropdown <- function(id, label = NULL, choices, ..., testid) {
        shinyWidgets::pickerInput(
          inputId = id,
          label = label,
          choices = choices,
          ...
        ) |>
          testable_component(
            id = id,
            testid = testid,
            testtype = "shinyWidgets::pickerInput"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          shiny::div(
            class = "d-none",
            dropdown(
              id = "test2-picker",
              label = "Letter",
              choices = c("A", "B"),
              testid = "Letter"
            )
          )
        ),
        server = function(input, output) {}
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$is_visible("Letter")

    expect_false(result)
  })

  it("should return TRUE if element is visible", {
    # Arrange
    make_app <- function() {
      dropdown <- function(id, label = NULL, choices, ..., testid) {
        shinyWidgets::pickerInput(
          inputId = id,
          label = label,
          choices = choices,
          ...
        ) |>
          testable_component(
            id = id,
            testid = testid,
            testtype = "shinyWidgets::pickerInput"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          dropdown(
            id = "test2-picker",
            label = "Letter",
            choices = c("A", "B"),
            testid = "Letter"
          )
        ),
        server = function(input, output) {}
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$is_visible("Letter")

    expect_true(result)
  })
})
