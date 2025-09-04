dropdown <- function(id, label = NULL, choices, ..., testid) {
  shiny::selectInput(
    inputId = id,
    label = label,
    choices = choices,
    ...
  ) |>
    shinytest3::testable_component(
      id = id,
      testid = testid,
      testtype = "dropdown"
    )
}

plot_output <- function(outputId, ..., testid) {
  shiny::plotOutput(
    outputId = outputId,
    ...
  ) |>
    shinytest3::testable_component(
      id = outputId,
      testid = testid,
      testtype = "plot_output"
    )
}
