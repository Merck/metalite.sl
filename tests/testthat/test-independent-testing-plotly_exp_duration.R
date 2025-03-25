
# Prepare data
meta <- meta_sl_exposure_example()

outdata <- meta |> prepare_exp_duration()


outdata_plot <- outdata|>
  extend_exp_duration(
    duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
    duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  )


# Testing the plotly_exp_duration function - run multiple plots
test_that("Interactive plot is created successfully", {
  
  interactive_plot <- outdata_plot |> plotly_exp_duration(plot_type_label = c("Histogram", "Stacked histogram", "Horizontal histogram"))
  
  expect_s3_class(interactive_plot, "shiny.tag.list")
  
  expect_snapshot(interactive_plot)
})








