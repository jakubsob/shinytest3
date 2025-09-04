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
      data_testable_type = "dropdown"
    )
}

plot_output <- function(outputId, ..., testable_id) {
  shiny::plotOutput(
    outputId = outputId,
    ...
  ) |>
    shinytest3::testable_component(
      id = outputId,
      data_testable_id = testable_id,
      data_testable_type = "plot_output"
    )
}
