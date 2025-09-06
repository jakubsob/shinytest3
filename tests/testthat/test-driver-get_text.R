describe("driver$get_text", {
  it("should return inner text of target component", {
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
        server = function(input, output) {

        }
      )
    }
    d <- Driver$new(make_app())
    on.exit(d$stop())

    # Act
    result <- d$get_text("header")

    # Assert
    expect_equal(result, "Header")
  })
})
