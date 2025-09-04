ui <- function(id) {
  ns <- NS(id)
  bslib::page(
    bslib::card(
      title = "Iris Dataset Visualization",
      bslib::card_body(
        dropdown(
          ns("x_var"),
          label = "X-axis variable:",
          choices = names(iris)[1:4],
          selected = NULL,
          testid = "X variable"
        ),
        dropdown(
          ns("y_var"),
          label = "Y-axis variable:",
          choices = names(iris)[1:4],
          selected = NULL,
          testid = "Y variable"
        ),
        plot_output(ns("iris_plot"), testid = "scatterplot")
      )
    )
  )
}
