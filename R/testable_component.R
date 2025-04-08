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
      `data-testable-shinyid` = id,
      `data-testable-id` = normalize_js_value(data_testable_id),
      `data-testable-type` = normalize_js_value(data_testable_type)
    )
}

normalize_js_value <- function(x) {
  x <- gsub(" ", "_", x)
  x
}
