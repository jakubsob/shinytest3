test_that("driver$get_text should return inner text of target component", {
  # Arrange
  make_app <- function() {
    shiny::shinyApp(
      ui = bslib::page_fluid(
        theme = bslib::bs_theme(version = 5),
        shiny::h2(
          `data-testid` = "header",
          "Header"
        )
      ),
      server = function(input, output) {}
    )
  }
  driver <- Driver$new(make_app())

  # Act
  result <- driver$get_text("header")

  # Assert
  expect_equal(result, "Header")

  # Teardown
  driver$stop()
})
