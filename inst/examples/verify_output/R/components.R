dropdown <- function(id, label = NULL, choices, ..., testable_id) {
  shiny::selectInput(
    inputId = id,
    label = label,
    choices = choices,
    ...
  ) |>
    shinytest3::testable_component(
      id = id,
      data_testable_id = testable_id,
      data_testable_type = "shiny::selectInput"
    )
}

plot_output <- function(outputId, ...) {
  shiny::plotOutput(
    outputId = outputId,
    ...
  )
}
