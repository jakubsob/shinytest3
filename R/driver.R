#' @keywords internal
#' @importFrom cli cli_abort
get_attr <- function(selector, attr, driver) {
  code <- sprintf(
    '$("[%s=%s]").attr("%s")',
    data_attr(option_testid()),
    normalize_js_value(selector),
    attr
  )
  result <- driver$get_js(script = code)
  if (length(result) == 0) {
    cli_abort("Element not found.")
  }
  if (length(result) > 1) {
    cli_abort("Multiple elements found.")
  }
  result
}

#' @keywords internal
#' @importFrom cli cli_abort
#' @importFrom purrr set_names
#' @importFrom glue glue
get_id <- function(selector, driver) {
  # We assume that the tag with ID is the wrapper of the component or a child
  code <- sprintf(
    '$("[%s=%s]:visible").length',
    data_attr(option_testid()),
    normalize_js_value(selector)
  )
  # driver$wait_for_js(sprintf("!!%s", code))
  length <- driver$get_js(script = code)
  if (length == 0) {
    cli_abort(c(
      "x" = glue::glue(
        "No inputs found with [{data_attr(option_testid())}={normalize_js_value(selector)}]"
      ),
      "i" = "Is this element visible?"
    ))
  }

  if (length > 1) {
    code <- sprintf(
      '[...$("[%s=%s]")].map(e => $(e).attr("data-testable-shinyid") )',
      data_attr(option_testid()),
      normalize_js_value(selector)
    )
    ids <- driver$get_js(script = code) |> as.character()
    cli_abort(c(
      "x" = glue(
        "Multiple inputs found with [{data_attr(option_testid())}={normalize_js_value(selector)}]"
      ),
      set_names(ids, rep("*", length(ids)))
    ))
  }

  get_attr(selector, data_attr(option_testshinyid()), driver)
}

#' @keywords internal
get_testable_type <- function(selector, driver) {
  get_attr(selector, data_attr(option_testtype()), driver)
}

#' Robust App Driver
#'
#' Instead of using Shiny IDs of components, use `data-testable-id` that can change independently from Shiny IDs.
#'
#' Easily detect what is the component we're interacting with using `data-testable-type` to dispatch a proper action.
#'
#' @export
#' @import R6
#' @importFrom shinytest2 AppDriver
#' @importFrom rlang is_missing missing_arg
Driver <- R6::R6Class(
  inherit = shinytest2::AppDriver,
  cloneable = FALSE,
  public = list(
    #' @param testable_id character
    #' @param ... Object
    dispatch = function(testable_id, ...) {
      id <- get_id(testable_id, super)
      testable_type <- get_testable_type(testable_id, super)
      x <- structure(list(...), class = testable_type)
      action(x, id = id, driver = super)
    },
    #' @param testable_id character
    #' @param input character
    #' @param output character
    #' @param export character
    get_value = function(testable_id = missing_arg(), input = missing_arg(), output = missing_arg(), export = missing_arg()) {
      if (!is_missing(testable_id)) {
        id <- get_id(testable_id, super)
        return(super$get_value(input = id))
      }
      super$get_value(input = input, output = output, export = export)
    }
    # Maybe extend also other methods of shinytest::AppDriver to use `data-testable-id`.
  )
)
