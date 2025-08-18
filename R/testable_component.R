#' Testable component
#'
#' @param x A widget
#' @param id A string, the ID of the widget
#' @param data_testable_id A string, the testable ID of the widget
#' @param data_testable_type A string, the testable type of the widget
#' @export
#' @importFrom htmltools tagAppendAttributes
testable_component <- function(x, id, data_testable_id, data_testable_type = NULL) {
  x |>
    tagAppendAttributes(
      !!data_attr(option_testshinyid()) := id,
      !!data_attr(option_testid()) := normalize_js_value(data_testable_id),
      !!data_attr(option_testtype()) := normalize_js_value(data_testable_type)
    )
}

data_attr <- function(x) {
  sprintf("data-%s", x)
}

normalize_js_value <- function(x) {
  x <- gsub(" ", "_", x)
  x
}
