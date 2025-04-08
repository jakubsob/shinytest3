source("R/ui.R")
source("R/server.R")
source("R/components.R")

shiny::shinyApp(
  ui = ui("app"),
  server = function(input, output) {
    server("app")
  }
)
