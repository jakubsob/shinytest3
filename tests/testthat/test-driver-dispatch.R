describe("driver$dispatch", {
  it("should dispatch default action", {
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
            id = "test-picker",
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
    d$dispatch("Letter", value = "B")

    # Assert
    expect_equal(d$get_value(testid = "Letter"), "B")
  })

  it("should dispatch action to the visible component", {
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
            id = "test-picker",
            label = "Letter",
            choices = c("A", "B"),
            testid = "Letter"
          ),
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
    d$dispatch("Letter", value = "B")

    # Assert
    expect_equal(d$get_value(testid = "Letter"), "B")
    expect_equal(d$get_value(input = "test2-picker"), "A")
  })

  it("should throw an error if multiple targets are found with given id", {
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
            id = "test-picker1",
            label = "Letter",
            choices = c("A", "B"),
            testid = "Letter"
          ),
          dropdown(
            id = "test-picker2",
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

    # Act, Assert
    expect_snapshot_error(d$dispatch("Letter", value = "B"))
  })

  it("should throw an error if no targets are found with given id", {
    # Arrange
    make_app <- function() {
      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5)
        ),
        server = function(input, output) {}
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act, Assert
    expect_snapshot_error(d$dispatch("Letter", value = "B"))
  })
})
