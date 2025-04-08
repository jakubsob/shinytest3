server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$iris_plot <- renderPlot({
      x <- iris[[input$x_var]]
      y <- iris[[input$y_var]]
      stopifnot(input$x_var != input$y_var)
      plot(
        x,
        y,
        xlab = input$x_var,
        ylab = input$y_var,
        main = "Scatter Plot of Iris Dataset",
        col = iris$Species,
        pch = 19
      )
      legend("topright", legend = levels(iris$Species), col = 1:3, pch = 19)
    })
  })
}
