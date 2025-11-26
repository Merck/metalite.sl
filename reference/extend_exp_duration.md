# Add cumulative count and summary stats for categories for exposure duration analysis

Add cumulative count and summary stats for categories for exposure
duration analysis

## Usage

``` r
extend_exp_duration(
  outdata,
  category_section_label = paste0(metalite::collect_adam_mapping(outdata$meta,
    outdata$parameter)$label, " (extend)"),
  duration_category_list = extract_duration_category_ranges(duration_category_labels),
  duration_category_labels =
    levels(outdata$meta$data_population[[metalite::collect_adam_mapping(outdata$meta,
    outdata$parameter)$vargroup]])
)
```

## Arguments

- outdata:

  An `outdata` object created by
  [`prepare_exp_duration()`](https://merck.github.io/metalite.sl/reference/prepare_exp_duration.md).

- category_section_label:

  A character value of section label. If `NULL`, the parameter label is
  used with "(cumulative)".

- duration_category_list:

  A list of duration category ranges. Must be real numbers and may
  overlap or be mutually exclusive. A list should be in the form of
  `list(c(low1, high1), c(low2, high2), ...)`. If `NA` is included in
  the range, it is treated as `-Inf` or `Inf`. The range is defined as
  `low <= x < high` for each.

- duration_category_labels:

  A character vector of internal labels. Labels to be displayed for the
  duration_category_list values. Must be the same length as
  duration_category_list.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- meta_sl_exposure_example()
outdata <- meta |> prepare_exp_duration()
outdata |>
  extend_exp_duration(
    duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
    duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
  )
#> List of 19
#>  $ meta            :List of 7
#>  $ population      : chr "apat"
#>  $ observation     : chr "apat"
#>  $ parameter       : chr "expdur"
#>  $ n               :'data.frame':    1 obs. of  6 variables:
#>  $ order           : NULL
#>  $ group           : chr "TRTA"
#>  $ reference_group : NULL
#>  $ char_n          :List of 1
#>  $ char_var        : chr "AVAL"
#>  $ char_prop       :List of 1
#>  $ var_type        :List of 1
#>  $ group_label     : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis        : chr "exp_dur"
#>  $ char_stat_groups:List of 5
#>  $ char_n_cum      :List of 1
#>  $ char_prop_cum   :List of 1
#>  $ char_stat_cums  :List of 5
#>  $ extend_call     :List of 1
```
