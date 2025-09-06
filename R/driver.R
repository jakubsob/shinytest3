get <- function(selector, code = "(x) => { return(x) }") {
  sprintf(
    '(%s)($("[%s=%s]"));',
    code,
    data_attr(option_testid()),
    normalize_js_value(selector)
  )
}

get_attr <- function(selector, attr) {
  get(selector, sprintf('(el) => el.attr("%s")', attr))
}

get_visible <- function(selector) {
  get(selector, '(el) => el.is(":visible")')
}

get_disabled <- function(selector) {
  get(selector, '(el) => el.is(":disabled")')
}

get_testtype <- function(selector) {
  get_attr(selector, data_attr(option_testtype()))
}

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
    cli::cli_abort(c(
      "x" = glue::glue(
        "No inputs found with [{data_attr(option_testid())}={normalize_js_value(selector)}]"
      ),
      "i" = "Is this element visible?"
    ))
  }

  if (length > 1) {
    code <- sprintf(
      '[...$("[%s=%s]")].map(e => $(e).attr("%s") )',
      data_attr(option_testid()),
      normalize_js_value(selector),
      data_attr(option_testshinyid())
    )
    ids <- driver$get_js(script = code) |> as.character()
    cli::cli_abort(c(
      "x" = glue::glue(
        "Multiple inputs found with [{data_attr(option_testid())}={normalize_js_value(selector)}]"
      ),
      purrr::set_names(ids, rep("*", length(ids)))
    ))
  }

  driver$get_js(get_attr(selector, data_attr(option_testshinyid())))
}

#' Robust App Driver
#'
#' Instead of using Shiny IDs of components, use `data-testable-id` that can change independently from Shiny IDs.
#'
#' Easily detect what is the component we're interacting with using `data-testable-type` to dispatch a proper action.
#'
#' @export
#' @importFrom rlang is_missing missing_arg
#' @importFrom shinytest2 AppDriver
#' @import testthat
#' @import R6
Driver <- R6::R6Class(
  inherit = shinytest2::AppDriver,
  cloneable = FALSE,
  public = list(
    #' @param testid character
    #' @param ... Object
    dispatch = function(testid, ...) {
      super$wait_for_idle()
      id <- get_id(testid, super)
      testable_type <- super$get_js(get_testtype(testid))
      x <- structure(list(...), class = testable_type)
      action(x, id = id, driver = super)
    },
    #' @param testid character
    #' @param input character
    #' @param output character
    #' @param export character
    get_value = function(
      testid = missing_arg(),
      input = missing_arg(),
      output = missing_arg(),
      export = missing_arg()
    ) {
      super$wait_for_idle()
      if (!is_missing(testid)) {
        id <- get_id(testid, super)
        return(super$get_value(input = id))
      }
      super$get_value(input = input, output = output, export = export)
    },
    #' @param testid character
    #' @param code character
    get = function(testid, code) {
      super$wait_for_idle()
      super$get_js(get(testid, code))
    },
    #' @param testid character
    is_visible = function(testid) {
      super$wait_for_idle()
      super$get_js(get_visible(testid))
    },
    #' @param testid character
    is_disabled = function(testid) {
      super$wait_for_idle()
      super$get_js(get_disabled(testid))
    },
    #' @description
    #'
    #' Fails a test when there are Shiny errors visible on the page
    verify_no_output_errors = function() {
      code <- sprintf(
        '$(".shiny-output-error:not(.shiny-output-error-validation):visible").length'
      )
      n <- super$get_js(script = code)
      if (n == 0) {
        testthat::succeed("No errors visible")
        return()
      }
      code <- sprintf(
        '[...$(".shiny-output-error:not(.shiny-output-error-validation):visible")]
      .map(x => $(x).attr("id"))'
      )
      ids <- super$get_js(script = code)
      testthat::fail(c(
        "Shiny errors found!",
        glue::glue(
          "  {cli::symbol$info} Outputs with given IDs produced an error:"
        ),
        paste("   ", cli::symbol$bullet, ids)
      ))
    }
    # Maybe extend also other methods of shinytest::AppDriver to use `data-testable-id`.
  )
)
