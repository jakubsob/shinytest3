# verify_output

    Code
      testthat::test_dir(tests_path, reporter = testthat::ProgressReporter$new(
        show_praise = FALSE), stop_on_failure = FALSE, ...)
    Output
      v | F W  S  OK | Context
      x | 1        0 | scatter
      --------------------------------------------------------------------------------
      Failure ('test-scatter.R:12:5'): Scatter: should show a scatter plot for selected variables
      Expected 0 shiny errors, but found 1
      i Outputs with given IDs produced an error:
      * app-iris_plot
      --------------------------------------------------------------------------------
      == Results =====================================================================
      
      -- Failed tests ----------------------------------------------------------------
      Failure ('test-scatter.R:12:5'): Scatter: should show a scatter plot for selected variables
      Expected 0 shiny errors, but found 1
      i Outputs with given IDs produced an error:
      * app-iris_plot
      [ FAIL 1 | WARN 0 | SKIP 0 | PASS 0 ]

