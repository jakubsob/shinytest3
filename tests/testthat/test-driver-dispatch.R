describe("driver$dispatch", {
  it("should dispatch default action", {
    # Arrange
    make_app <- function() {
      dropdown <- function(id, label = NULL, choices, ..., data_testable_id) {
        shinyWidgets::pickerInput(
          inputId = id,
          label = label,
          choices = choices,
          ...
        ) |>
          testable_component(
            id = id,
            data_testable_id = data_testable_id,
            data_testable_type = "shinyWidgets::pickerInput"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          dropdown(
            id = "test-picker",
            label = "Letter",
            choices = c("A", "B"),
            data_testable_id = "Letter"
          )
        ),
        server = function(input, output) {

        }
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    d$dispatch("Letter", value = "B")

    # Assert
    expect_equal(d$get_value(testable_id = "Letter"), "B")
  })

  it("should dispatch action to the visible component", {
    # Arrange
    make_app <- function() {
      dropdown <- function(id, label = NULL, choices, ..., data_testable_id) {
        shinyWidgets::pickerInput(
          inputId = id,
          label = label,
          choices = choices,
          ...
        ) |>
          testable_component(
            id = id,
            data_testable_id = data_testable_id,
            data_testable_type = "shinyWidgets::pickerInput"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          dropdown(
            id = "test-picker",
            label = "Letter",
            choices = c("A", "B"),
            data_testable_id = "Letter"
          ),
          shiny::div(
            class = "d-none",
            dropdown(
              id = "test2-picker",
              label = "Letter",
              choices = c("A", "B"),
              data_testable_id = "Letter"
            )
          )
        ),
        server = function(input, output) {

        }
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    d$dispatch("Letter", value = "B")

    # Assert
    expect_equal(d$get_value(testable_id = "Letter"), "B")
    expect_equal(d$get_value(input = "test2-picker"), "A")
  })
})
