# Format Disposition Analysis

Format Disposition Analysis

## Usage

``` r
format_disposition(
  outdata,
  display_col = c("n", "prop", "total"),
  digits_prop = 1,
  display_stat = c("mean", "sd", "se", "median", "q1 to q3", "range")
)
```

## Arguments

- outdata:

  A metadata object created by
  [`prepare_sl_summary()`](https://merck.github.io/metalite.sl/reference/prepare_sl_summary.md).

- display_col:

  Column wants to display on the table. The term could be selected from
  `c("n", "prop", "total")`.

- digits_prop:

  Number of digits for proportion columns.

- display_stat:

  A vector of statistics term name. The term name could be selected from
  `c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")`.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- metalite::meta_adam(
  population = metalite_sl_adsl,
  observation = metalite_sl_adsl
) |>
  metalite::define_plan(metalite::plan(
    analysis = "disp", population = "apat",
    observation = "apat", parameter = "disposition;medical-disposition"
  )) |>
  metalite::define_population(
    name = "apat", group = "TRTA", subset = SAFFL == "Y"
  ) |>
  metalite::define_parameter(
    name = "disposition", var = "EOSSTT", label = "Trial Disposition",
    var_lower = "DCSREAS"
  ) |>
  metalite::define_parameter(
    name = "medical-disposition", var = "EOTSTT",
    label = "Participant Study Medication Disposition", var_lower = "DCTREAS"
  ) |>
  metalite::define_analysis(
    name = "disp", title = "Disposition of Participant"
  ) |>
  metalite::meta_build()
#> Warning: disp: has missing label

meta |>
  prepare_disposition(population = "apat", parameter = "disposition;medical-disposition") |>
  format_disposition()
#> List of 17
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "disposition;medical-disposition"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 2
#>  $ char_var       : chr [1:2] "EOSSTT" "EOTSTT"
#>  $ char_prop      :List of 2
#>  $ var_type       :List of 2
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "disp"
#>  $ tbl            :'data.frame': 15 obs. of  10 variables:
#>  $ display_col    : chr [1:3] "n" "prop" "total"
#>  $ display_stat   : chr [1:6] "mean" "sd" "se" "median" ...
```
