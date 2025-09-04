#' Testable component
#'
#' @param x A widget
#' @param id A string, the ID of the widget
#' @param testid A string, the testable ID of the widget
#' @param testtype A string, the testable type of the widget
#' @export
#' @importFrom htmltools tagAppendAttributes
testable_component <- function(x, id, testid, testtype = NULL) {
  x |>
    tagAppendAttributes(
      !!data_attr(option_testshinyid()) := id,
      !!data_attr(option_testid()) := normalize_js_value(testid),
      !!data_attr(option_testtype()) := normalize_js_value(testtype)
    )
}

data_attr <- function(x) {
  sprintf("data-%s", x)
}

normalize_js_value <- function(x) {
  x <- gsub(" ", "_", x)
  x
}
