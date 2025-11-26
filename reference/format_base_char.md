# Format Baseline Characteristics Analysis

Format Baseline Characteristics Analysis

## Usage

``` r
format_base_char(
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
meta <- meta_sl_example()

meta |>
  prepare_base_char(population = "apat", parameter = "age;gender") |>
  format_base_char()
#> List of 17
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age;gender"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 2
#>  $ char_var       : chr [1:2] "AGE" "SEX"
#>  $ char_prop      :List of 2
#>  $ var_type       :List of 2
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "base_char"
#>  $ tbl            :'data.frame': 13 obs. of  10 variables:
#>  $ display_col    : chr [1:3] "n" "prop" "total"
#>  $ display_stat   : chr [1:6] "mean" "sd" "se" "median" ...
```
