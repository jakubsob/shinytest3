# #' @title Verify Shiny app output
# #' @param driver A driver object.
# #' @export
# #' @importFrom purrr set_names
# #' @importFrom cli cli_warn
# warn_if_validation_error <- function(driver) {
#   code <- sprintf('$(".shiny-output-error-validation:visible").length')
#   n <- driver$get_js(script = code)
#   if (n == 0) {
#     return()
#   }
#   code <- sprintf(
#     '[...$(".shiny-output-error-validation:visible")]
#       .map(x => $(x).attr("id"))'
#   )
#   ids <- driver$get_js(script = code)
#   cli_warn(
#     c(
#       "!" = "Outputs with given IDs were suppressed with validation:",
#       set_names(ids, rep("*", length(ids)))
#     )
#   )
# }

# #' @title Verify Shiny app output
# #' @param driver A driver object.
# #' @export
# #' @importFrom purrr set_names
# #' @importFrom cli cli_warn
# warn_if_empty_output <- function(driver) {
#   code <- sprintf(
#     '[...$(".shiny-bound-output:not(.shiny-output-error):visible")]
#       .filter(x => $(x).css("height") === "0px")
#       .length'
#   )
#   n <- driver$get_js(script = code)
#   if (n == 0) {
#     return()
#   }
#   code <- sprintf(
#     '[...$(".shiny-bound-output:not(.shiny-output-error):visible")]
#       .filter(x => $(x).css("height") === "0px")
#       .map(x => $(x).attr("id"))'
#   )
#   ids <- driver$get_js(script = code)
#   cli_warn(
#     c(
#       "!" = "Outputs with given IDs are empty:",
#       set_names(ids, rep("*", length(ids)))
#     )
#   )
# }
