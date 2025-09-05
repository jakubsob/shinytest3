describe("driver$get", {
  it("should return value of jQuery code ran on the target", {
    # Arrange
    make_app <- function() {
      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          shiny::plotOutput("plot") |>
            testable_component(
              id = "plot",
              testid = "scatterplot",
              testtype = "plot_output"
            )
        ),
        server = function(input, output) {
          output$plot <- shiny::renderPlot({
            plot(
              iris$Sepal.Length,
              iris$Petal.Width,
              main = "Scatter Plot of Iris Dataset",
              col = iris$Species,
              pch = 19
            )
          })
        }
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$get("scatterplot", '.find("img").attr("src")')

    # Assert
    expect_true(startsWith(result, "data:image/png"))
  })

  it("should return NULL if jQuery code isn't valid", {
    # Arrange
    make_app <- function() {
      shiny::shinyApp(
        ui = bslib::page_fluid(
          theme = bslib::bs_theme(version = 5),
          shiny::plotOutput("plot") |>
            testable_component(
              id = "plot",
              testid = "scatterplot",
              testtype = "plot_output"
            )
        ),
        server = function(input, output) {
          output$plot <- shiny::renderPlot({
            plot()
          })
        }
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$get("scatterplot", '.find("img").attr("src")')

    # Assert
    expect_null(result)
  })
})
