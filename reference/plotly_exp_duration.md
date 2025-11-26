# Create an interactive plot for exposure duration

Create an interactive plot for exposure duration

## Usage

``` r
plotly_exp_duration(
  outdata,
  color = NULL,
  display = c("n", "prop"),
  display_total = TRUE,
  display_standard_histogram = TRUE,
  standard_histogram_label =
    "Comparison of Exposure Duration (> = x days) by Treatment Groups",
  display_stacked_histogram = TRUE,
  stacked_histogram_label =
    "Comparison of Exposure Duration (> = x days and < y days) by Treatment Groups",
  display_horizontal_histogram = TRUE,
  horizontal_histogram_label = "Comparison by Exposure Duration (> = x days)",
  plot_group_label = "Treatment group",
  plot_category_label = "Exposure duration",
  hover_summary_var = c("n", "median", "sd", "se", "median", "min", "max", "q1 to q3",
    "range"),
  width = 1000,
  height = 400
)
```

## Arguments

- outdata:

  An `outdata` object created from
  [`prepare_exp_duration()`](https://merck.github.io/metalite.sl/reference/prepare_exp_duration.md).
  [`extend_exp_duration()`](https://merck.github.io/metalite.sl/reference/extend_exp_duration.md)
  can also be applied.

- color:

  Color for a histogram.

- display:

  A character vector of display type. `n` or `prop` can be selected.

- display_total:

  A logical value to display total.

- display_standard_histogram:

  A logical value if the standard histogram is displayed.

- standard_histogram_label:

  A character value of label for the standard histogram.

- display_stacked_histogram:

  A logical value if the stacked histogram is displayed.

- stacked_histogram_label:

  A character value of label for the stacked histogram.

- display_horizontal_histogram:

  A logical value if the horizontal histogram is displayed.

- horizontal_histogram_label:

  A character value of label for

- plot_group_label:

  A label for grouping.

- plot_category_label:

  A label for category.

- hover_summary_var:

  A character vector of statistics to be displayed on hover label of
  bar.

- width:

  Width of the plot.

- height:

  Height of the plot.

## Value

Interactive plot for exposure duration.

## Examples

``` r
# Only run this example in interactive R sessions
if (interactive()) {
  meta <- meta_sl_exposure_example()
  outdata <- meta |>
    prepare_exp_duration() |>
    extend_exp_duration(
      duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
      duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
    )

  outdata |> plotly_exp_duration()
}
```
