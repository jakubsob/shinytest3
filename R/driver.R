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

make_testid_selector <- function(selector) {
  sprintf('[%s="%s"]', data_attr(option_testid()), normalize_js_value(selector))
}

#' Driver
#'
#' @description
#' A layer extending `shinytest2::AppDriver`. Instead of relying on fragile Shiny IDs, this driver
#' uses semantic test identifiers that can change independently from application logic.
#'
#' @details
#' The Driver class provides a reliable testing framework by:
#'
#' * Using `testid` attributes for component identification instead of Shiny IDs
#' * Automatically detecting component types via `testtype` attributes
#' * Dispatching appropriate actions based on component type (`testtype`)
#' * Providing error checking and user-observable state validation
#'
#' Components should be wrapped with [testable_component()] to add the necessary
#' data attributes for this driver to work properly.
#'
#' ```r
#' # Wrap a component used in the app in a function.
#' # Use testable_component() to attach test attrubutes.
#' dropdown <- function(id, label = NULL, choices, ..., testid) {
#'   shinyWidgets::pickerInput(
#'     inputId = id,
#'     label = label,
#'     choices = choices,
#'     ...
#'   ) |>
#'     testable_component(
#'       id = id,
#'       testid = testid,
#'       testtype = "dropdown"
#'     )
#' }
#'
#' app <- shiny::shinyApp(
#'   ui = bslib::page_fluid(
#'     # Attach a unique testid for each visible component
#'     dropdown(
#'       id = "test-picker",
#'       label = "Letter",
#'       choices = c("A", "B"),
#'       testid = "Letter"
#'     )
#'   ),
#'   server = function(input, output) {}
#' )
#'
#' d <- Driver$new(app)
#'
#' # Dispatch an action to "Letter" component. It sets the value to "B".
#' # Custom action wasn't registered for `testtype = "dropdown"`,
#' # `shinytest2::AppDriver$set_inputs` will be used to set the value.
#' d$dispatch("Letter", value = "B")
#'
#' # Get the value of "Letter" component.
#' d$get_value(testid = "Letter") # Will return "B"
#' ```
#'
#' @seealso [testable_component()] for preparing components for testing
#' @seealso [shinytest2::AppDriver] for the underlying driver functionality
#'
#' @examples
#' \dontrun{
#' # Initialize a driver for testing
#' driver <- Driver$new(app_dir = "path/to/app")
#'
#' # Interact with components using testid
#' driver$dispatch("Species", value = "Setosa")
#'
#' # Check component state
#' driver$is_visible("Species distribution")
#'
#' # Get component values
#' current_value <- driver$get_value(testid = "Species")
#'
#' # Verify no errors are present
#' driver$expect_output_errors(n = 0)
#' }
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
    #' @description
    #' Dispatch an action to a component based on its type
    #'
    #' This method automatically detects the component type using the `testtype`
    #' attribute and dispatches the appropriate action. The action system uses S3
    #' method dispatch to handle different component types appropriately.
    #'
    #' You can register your own custom actions by extending the `action` class:
    #'
    #' ```{r, eval=FALSE}
    #' action.dropdown <- function(x, ...) {
    #'   # Open the dropdown
    #'   # Click on a choice
    #' }
    #' ```
    #'
    #' If custom action isn't registered, it falls back to `shinytest2::AppDriver$set_inputs`.
    #'
    #' @param testid A character string identifying the component via its `testid` attribute
    #' @param ... Additional arguments passed to the component-specific action method.
    #'   Common arguments include `value` for setting input values.
    #'
    #'   Arguments passed to custom `action` implementation.
    #'
    #' @details
    #' The dispatch system works as follows:
    #' 1. Waits for the app to be idle
    #' 2. Validates that the target component is findable and visible
    #' 3. Extracts the Shiny ID and component type from data attributes
    #' 4. Creates an object with the specified class (component type)
    #' 5. Calls the appropriate `action.*` method for that component type
    #'
    #' @examples
    #' \dontrun{
    #' # Set value for a text input
    #' driver$dispatch("Username", value = "John Doe")
    #'
    #' # Click a button (no additional arguments needed)
    #' driver$dispatch("Submit")
    #'
    #' # Set multiple selection for a picker input
    #' driver$dispatch("Species", value = c("Setosa"))
    #' }
    #'
    #' @return Invisible NULL. Called for side effects.
    dispatch = function(testid, ...) {
      super$wait_for_idle()
      assert_target_findable(testid, super)
      id <- super$get_js(get_testshinyid(testid))
      testable_type <- super$get_js(get_testtype(testid))
      x <- structure(list(...), class = testable_type)
      action(x, id = id, driver = super)
    },
    #' @description
    #' Get the current value of an input component
    #'
    #' Retrieves the current value of a Shiny input either by testid or by direct
    #' input/output/export name.
    #'
    #' @param testid A character string identifying the component via its `testid`
    #'   attribute. If provided, other parameters are ignored.
    #' @param input A character string specifying the input name directly. For compatibility with shinytest2.
    #' @param output A character string specifying the output name directly. For compatibility with shinytest2.
    #' @param export A character string specifying the export name directly. For compatibility with shinytest2.
    #'
    #' @return The current value of the specified input, output, or export.
    #'   Return type depends on the component type (e.g., character, numeric, list).
    #'
    #' @details
    #' When `testid` is provided:
    #' 1. Waits for the app to be idle
    #' 2. Validates that the target component exists and is findable
    #' 3. Extracts the Shiny ID from the `testshinyid` attribute
    #' 4. Returns the value using the resolved ID
    #'
    #' When direct names are provided, behaves like the standard `shinytest2::AppDriver$get_value()`.
    #'
    #' @examples
    #' \dontrun{
    #' # Get value using testid (recommended)
    #' current_text <- driver$get_value(testid = "Username")
    #'
    #' # Get value using direct input name (not recommended)
    #' current_text <- driver$get_value(input = "module-nested_module-username")
    #'
    #' # Get value using testid (recommended)
    #' plot_data <- driver$get_value(testid = "Scatterplot")
    #'
    #' # Get output value (not recommended)
    #' plot_data <- driver$get_value(output = "module-nested_module-main_plot")
    #' }
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
    #' @description
    #' Get the text content of a component
    #'
    #' Extracts the visible text content from a component, either by testid or by
    #' CSS selector. This is useful for reading labels, button text, output text,
    #' or any other textual content displayed in the app.
    #'
    #' @param testid A character string identifying the component via its `testid`
    #'   attribute. If provided, selector parameter is ignored.
    #' @param selector A CSS selector string for directly targeting elements
    #'   (alternative to testid)
    #'
    #' @return A character string containing the text content of the target element.
    #'   Returns empty string if no text is found.
    #'
    #' @details
    #' When `testid` is provided, the method:
    #' 1. Validates that the target component exists and is findable
    #' 2. Constructs a CSS selector using the testid
    #' 3. Extracts the text content from the matching element
    #'
    #' When `selector` is provided directly, it's passed through to the underlying
    #' `shinytest2::AppDriver$get_text()` method.
    #'
    #' @examples
    #' \dontrun{
    #' # Get text using testid (recommended)
    #' title_text <- driver$get_text(testid = "Title")
    #'
    #' # Get text using CSS selector (not recommended)
    #' title_text <- driver$get_text(selector = "h1.main-title")
    #' }
    get_text = function(
      testid = missing_arg(),
      selector = missing_arg()
    ) {
      if (!is_missing(testid)) {
        assert_target_findable(testid, super)
        selector <- make_testid_selector(testid)
      }
      super$get_text(selector = selector)
    },
    #' @description
    #' Execute custom JavaScript code on a component
    #'
    #' Runs arbitrary JavaScript code in the context of a specific component identified
    #' by testid. This provides a flexible way to interact with components or extract
    #' information that isn't available through other driver methods.
    #'
    #' @param testid A character string identifying the component via its `testid` attribute
    #' @param code A character string containing JavaScript code to execute. The code
    #'   receives the jQuery element(s) matching the testid as its parameter.
    #'
    #' @return The result of the JavaScript code execution. Type depends on what the
    #'   JavaScript code returns (could be character, numeric, logical, list, etc.).
    #'
    #' @details
    #' The method:
    #' 1. Waits for the app to be idle
    #' 2. Constructs a JavaScript call targeting the component with the specified testid
    #' 3. Executes the provided code with the component element(s) as context
    #' 4. Returns the result
    #'
    #' The JavaScript code parameter receives a jQuery object containing the matching elements.
    #'
    #' @examples
    #' \dontrun{
    #' # Get a custom attribute value
    #' custom_attr <- driver$get("Name", "(el) => el.attr('custom')")
    #'
    #' # Check if element has a specific CSS class
    #' has_class <- driver$get("Next step", "(el) => el.hasClass('active')")
    #'
    #' # Count child elements
    #' child_count <- driver$get("Results list", "(el) => el.children().length")
    #' }
    get = function(testid, code) {
      super$wait_for_idle()
      super$get_js(get(testid, code))
    },
    #' @description
    #' Check if a component is visible
    #'
    #' Determines whether a component is currently visible in the DOM. This checks
    #' CSS visibility, display properties, and jQuery's `:visible` pseudo-selector.
    #' Hidden, collapsed, or display:none elements will return FALSE.
    #'
    #' @param testid A character string identifying the component via its `testid` attribute
    #'
    #' @return A logical value: `TRUE` if the component is visible, `FALSE` otherwise.
    #'
    #' @details
    #' The method:
    #' 1. Waits for the app to be idle
    #' 2. Executes JavaScript to check the jQuery `:visible` selector status
    #' 3. Returns the boolean result
    #'
    #' This is particularly useful for:
    #' - Conditional UI elements that show/hide based on user input
    #' - Verifying that certain elements appear after actions
    #' - Testing responsive design behavior
    #' - Checking modal or popup visibility
    #'
    #' @examples
    #' \dontrun{
    #' # Check if an error message is visible
    #' if (driver$is_visible("Error message")) {
    #'   error_text <- driver$get_text(testid = "Error message")
    #' }
    #'
    #' # Verify a modal dialog appeared
    #' expect_true(driver$is_visible("Confirm"))
    #'
    #' # Check if conditional UI element is shown
    #' driver$dispatch("Show advanced options", value = TRUE)
    #' expect_true(driver$is_visible("Advanced options"))
    #' }
    is_visible = function(testid) {
      super$wait_for_idle()
      super$get_js(get_visible(testid))
    },
    #' @description
    #' Check if a component is disabled
    #'
    #' Determines whether a component is currently disabled. This checks the `disabled`
    #' attribute and property of HTML elements, which prevents user interaction.
    #'
    #' @param testid A character string identifying the component via its `testid` attribute
    #'
    #' @return A logical value: `TRUE` if the component is disabled, `FALSE` if enabled.
    #'
    #' @details
    #' The method:
    #' 1. Waits for the app to be idle
    #' 2. Executes JavaScript to check the jQuery `:disabled` selector status
    #' 3. Returns the boolean result
    #'
    #' This is useful for:
    #' - Verifying that form controls are properly disabled/enabled based on conditions
    #' - Testing input validation states
    #' - Checking button states during processing
    #' - Ensuring UI elements respond correctly to application state changes
    #'
    #' @examples
    #' \dontrun{
    #' # Check if submit button is disabled when form is invalid
    #' expect_true(driver$is_disabled("Submit"))
    #'
    #' # Verify input becomes enabled after conditions are met
    #' driver$dispatch("Enable options", value = TRUE)
    #' expect_false(driver$is_disabled("Options"))
    #' }
    is_disabled = function(testid) {
      super$wait_for_idle()
      super$get_js(get_disabled(testid))
    },
    #' @description
    #' Verify the expected number of Shiny output errors
    #'
    #' Checks for visible Shiny error messages on the page and fails the test if the
    #' actual number doesn't match the expected count. This is crucial for testing
    #' error handling and ensuring your app displays appropriate error messages.
    #'
    #' @param n An integer specifying the expected number of visible Shiny output errors.
    #'   Defaults to 0 (no errors expected).
    #'
    #' @return Invisible NULL. Called for side effects (test success/failure).
    #'
    #' @details
    #' The method:
    #' 1. Counts visible Shiny output errors (elements with class `.shiny-output-error`)
    #' 2. Excludes validation errors (`.shiny-output-error-validation`)
    #' 3. Compares the count to the expected number
    #' 4. If counts match, the test succeeds silently
    #' 5. If counts don't match, provides detailed failure information including
    #'    the IDs of outputs that produced errors
    #'
    #' This is typically used to verify that:
    #' - No unexpected errors occur during normal operation (`n = 0`)
    #' - Expected errors appear when testing error conditions (`n > 0`)
    #' - Error recovery works properly (errors disappear after fixes)
    #'
    #' @examples
    #' \dontrun{
    #' # Verify no errors during normal operation
    #' driver$expect_output_errors() # expects 0 errors
    #'
    #' # Test that invalid input produces exactly one error
    #' driver$dispatch("Category", value = "invalid")
    #' driver$expect_output_errors(n = 1) # expects 1 error
    #'
    #' driver$dispatch("Category", value = "valid")
    #' driver$expect_output_errors() # expects 0 errors
    #' }
    expect_output_errors = function(n = 0) {
      code <- sprintf(
        '$(".shiny-output-error:not(.shiny-output-error-validation):visible").length'
      )
      n_errors <- super$get_js(script = code)
      if (n_errors == n) {
        testthat::succeed("No visible shiny errors.")
        return()
      }
      code <- sprintf(
        '[...$(".shiny-output-error:not(.shiny-output-error-validation):visible")].map(x => $(x).attr("%s"))',
        data_attr(option_testshinyid())
      )

      ids <- super$get_js(script = code)
      testthat::fail(c(
        glue::glue("Expected {n} shiny errors, but found {n_errors}"),
        glue::glue(
          "  {cli::symbol$info} Outputs with given IDs produced an error:"
        ),
        paste("   ", cli::symbol$bullet, ids)
      ))
    }
    # Maybe extend also other methods of shinytest::AppDriver to use `testable-id`.
  )
)
