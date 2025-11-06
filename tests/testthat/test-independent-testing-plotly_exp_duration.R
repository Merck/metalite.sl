# Prepare data
meta <- meta_sl_exposure_example()

outdata <- meta |> prepare_exp_duration()


outdata_plot <- outdata |>
  extend_exp_duration(
    duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
    duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  )

# Testing the plotly_exp_duration function - run multiple plots
test_that("Interactive plot is created successfully", {
  interactive_plot <- outdata_plot |>
    plotly_exp_duration(
      standard_histogram_label = "Histogram",
      stacked_histogram_label = "Stacked histogram",
      horizontal_histogram_label = "Horizontal histogram"
    )

  html <- gsub(
    "id=\"htmlwidget-[A-Za-z0-9]+\"",
    "id=\"htmlwidget-123456\"",
    as.character(interactive_plot)
  )

  html <- gsub(
    "for=\"htmlwidget-[A-Za-z0-9]+\"",
    "for=\"new_htmlwidget-123456\"",
    html
  )

  # Use gsub to replace 'id=\histogram_dropdown_' with something else, for example, 'dropdown'
  html <- gsub(
    "id=\"histogram_dropdown_[^\"]*\"",
    "id=\"dropdown-123456\"",
    html
  )

  # Use gsub to replace 'for=\histogram_dropdown_' with something else, for example, 'new_dropdown_'
  html <- gsub(
    "for=\"histogram_dropdown_[^\"]*\"",
    "for=\"new_dropdown_123456\"", # Replace with your desired value
    html
  )

  # Use gsub to replace 'id=\"histogram_type_' with something else, for example, 'type'
  html <- gsub(
    "id=\"histogram_type_[^\"]*\"",
    "id=\"type_123456\"", # Replace with your desired value
    html
  )

  # Use gsub to replace 'value=\"histogram_type_' with something else, for example, 'new_type'
  html <- gsub(
    "value=\"histogram_type_[^\"]*\"",
    "value=\"new_type_123456\"", # Replace with your desired value
    html
  )

  # Use gsub to replace the dynamic part after attrs":{\" with a fixed value
  html <- gsub(
    "attrs\":\\{\"[^\"]*\"",
    "attrs\":\"{attrs_value\"", # Replace with your desired new value
    html
  )

  # Use gsub to replace the dynamic part after cur_data\":\"10943968042c77\" with a fixed value, for example, 'new_cur_data'
  html <- gsub(
    "cur_data\":\"[^\"]*\"",
    "cur_data\":\"new_cur_data\"", # Replace with your desired new value
    html
  )

  # Use gsub to replace the dynamic part after "visdat\":{\"10d5f4785112cf\" with a fixed value, for example, 'new_visdat'
  html <- gsub(
    "visdat\":\\{\"[^\"]*\"",
    "visdat\":{\"new_visdat\"", # Replace with your desired new value
    html
  )

  expect_snapshot(html)
})
