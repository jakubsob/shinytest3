start_app <- function() {
  Driver$new(system.file("examples/verify_output", package = "shinytest3"))
}

describe("Scatter", {
  it("should show a scatter plot for selected variables", {
    app <- start_app()

    i_set("Y variable", "Sepal.Width", app)
    i_set("X variable", "Sepal.Width", app)

    verify_no_output_error(app)
  })
})
