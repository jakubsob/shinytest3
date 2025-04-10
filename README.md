
# shinytest3

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN status](https://www.r-pkg.org/badges/version/shinytest3)](https://CRAN.R-project.org/package=shinytest3)
[![R-CMD-check](https://github.com/jakubsob/shinytest3/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jakubsob/shinytest3/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/jakubsob/shinytest3/graph/badge.svg)](https://app.codecov.io/gh/jakubsob/shinytest3)
<!-- badges: end -->

> :construction: **This package is in development and not yet ready for production use.** :construction:

shinytest3 makes testing Shiny during development easier, with fewer reasons for tests to break when Shiny code changes.

shinytest3 is an extension of [shinytest2](https://github.com/r-lib/testthat/) that helps you write testable Shiny code, enables usage of [robust selectors](https://docs.cypress.io/app/core-concepts/best-practices#Selecting-Elements), and facilitates test code reuse.


# Why do you need {shinytest3}?

One of the reasons why shinytest2 tests tend to break after changes in Shiny code is their tight coupling with the structure of the app. This is because shinytest2 uses input IDs to find elements in the app. A change as simple as renaming an input or its parent module will cause tests to fail.

shinytest3 is designed to mitigate these issues by providing a more flexible approach to element selection.

Instead of relying on input IDs to find elements, shinytest3 introduces a `testable_component` which helps to target them from tests.

Then you can use an `action` to interact with the component.

# What happens with Shiny tests when you change Shiny code?

| Change in Shiny code        | {shinytest2}                | {shinytest3}                |
| --------------------------- | --------------------------- | --------------------------- |
| Add a new behavior/feature  | :heavy_plus_sign: Add tests | :heavy_plus_sign: Add tests |
| Rename an input             | :x: Fail                    | :white_check_mark: Pass     |
| Rename a module             | :x: Fail                    | :white_check_mark: Pass     |
| Change input values mapping | :x: Fail                    | :white_check_mark: Pass     |
