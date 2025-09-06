assert_target_findable <- function(selector, driver) {
  code <- get(selector, 'el => el.filter(":visible").length')
  length <- driver$get_js(code)

  if (length == 0) {
    attr_testid <- data_attr(option_testid())
    testid <- normalize_js_value(selector)
    cli::cli_abort(c(
      "x" = glue::glue(
        "No inputs found with [{attr_testid}={testid}]"
      ),
      "i" = "Is this element visible?"
    ))
  }

  if (length > 1) {
    attr_testid <- data_attr(option_testid())
    testid <- normalize_js_value(selector)
    code <- get(
      selector,
      sprintf(
        'el => [...el].map(e => $(e).attr("%s"))',
        data_attr(option_testshinyid())
      )
    )
    ids <- as.character(driver$get_js(code))
    cli::cli_abort(c(
      "x" = glue::glue(
        "Multiple inputs found with [{attr_testid}={testid}]"
      ),
      purrr::set_names(ids, rep("*", length(ids)))
    ))
  }
}

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

get_testshinyid <- function(selector) {
  get_attr(selector, data_attr(option_testshinyid()))
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
      assert_target_findable(testid, super)
      id <- super$get_js(get_testshinyid(testid))
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
      if (!is_missing(testid)) {
        super$wait_for_idle()
        assert_target_findable(testid, super)
        id <- super$get_js(get_testshinyid(testid))
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
