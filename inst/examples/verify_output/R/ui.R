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
          testable_id = "X variable"
        ),
        dropdown(
          ns("y_var"),
          label = "Y-axis variable:",
          choices = names(iris)[1:4],
          selected = NULL,
          testable_id = "Y variable"
        ),
        plot_output(ns("iris_plot"), testable_id = "scatterplot")
      )
    )
  )
}
