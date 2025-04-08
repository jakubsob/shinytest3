#' Action
#'
#' @param args A list of arguments to pass to the action.
#' @param id The ID of the component.
#' @param driver The driver object.
#' @param ... Additional arguments.
#'
#' @export
action <- function(args, id, driver, ...) {
  UseMethod("action")
}

#' @export
#' @importFrom rlang list2 `:=`
action.default <- function(args, id, driver, ...) {
  # cli::cli_warn("No action implemented for this component, attempting to set a value.")
  driver$set_inputs(!!!list2(!!id := args$value))
}

# `action.shinyWidgets::pickerInput` <- function(args, id, driver, ...) {
#   # driver$set_inputs(!!!rlang::list2(!!id := args$value))
#   # or
#   value <- jsonlite::toJSON(args$value, auto_unbox = TRUE)
#   driver$run_js(glue::glue("$('#{id}').selectpicker('val', {value});"))
# }

# `action.shinyWidgets::virtualSelectInput` <- function(args, id, driver, ...) {
#   # Implement Cypress style interactions
#   # 1. Wait for idle
#   # 2. Find the dropdown
#   # 3. Click on the button to reveal menu
#   # 4. Find the options and click
# }

# `action.shiny::actionButton` <- function(args, id, driver, ...) {
#   # Implement Cypress style interactions
#   # 1. Wait for table to be rendered
#   # 2. Find button
#   # 3. Click
#   driver$wait_for_idle()
#   driver$click(input = id)
# }

# action.reactableButton <- function(args, id, driver, ...) {
#   driver$click(selector = sprintf("#%s", id))
# }
