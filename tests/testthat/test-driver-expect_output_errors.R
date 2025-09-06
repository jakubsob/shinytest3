describe("driver$expect_output_errors", {
  it("should expect given no output errors by default", {
    # Arrange
    make_app <- function() {
      plot_output <- function(id, ..., testid) {
        shiny::plotOutput(id, ...) |>
          testable_component(
            id = id,
            testid = testid,
            testtype = "plot_output"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          plot_output("plot", testid = "iris distribution")
        ),
        server = function(input, output) {
          output$plot <- shiny::renderPlot({
            plot(iris$Sepal.Length, iris$Sepal.Width)
          })
        }
      )
    }
    d <- Driver$new(make_app())

    # Act, Assert
    expect_success(d$expect_output_errors())

    # Teardown
    d$stop()
  })

  it("should expect given number of output errors", {
    # Arrange
    make_app <- function() {
      plot_output <- function(id, ..., testid) {
        shiny::plotOutput(outputId = id, ...) |>
          testable_component(
            id = id,
            testid = testid,
            testtype = "plot_output"
          )
      }

      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          plot_output("plot1", testid = "iris distribution"),
          plot_output("plot2", testid = "mtcars distribution")
        ),
        server = function(input, output) {
          output$plot1 <- shiny::renderPlot({
            plot()
          })
          output$plot2 <- shiny::renderPlot({
            plot()
          })
        }
      )
    }
    d <- Driver$new(make_app())

    # Act, Assert
    expect_snapshot_failure(d$expect_output_errors(0))

    # Teardown
    d$stop()
  })
})
