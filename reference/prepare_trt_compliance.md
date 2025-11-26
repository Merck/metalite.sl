# Prepare data for treatment compliance table

Prepare data for treatment compliance table

## Usage

``` r
prepare_trt_compliance(
  meta,
  analysis = "trt_compliance",
  population = meta$plan[meta$plan$analysis == analysis, ]$population,
  parameter = paste(meta$plan[meta$plan$analysis == analysis, ]$parameter, collapse =
    ";")
)
```

## Arguments

- meta:

  A metadata object created by metalite.

- analysis:

  A character value of analysis term name. The term name is used as key
  to link information.

- population:

  A character value of population term name. The term name is used as
  key to link information.

- parameter:

  A character value of parameter term name. The term name is used as key
  to link information.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- meta_sl_example()
meta |> prepare_trt_compliance()
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "comp8;comp16;comp24"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 3
#>  $ char_var       : chr [1:3] "COMP8FL" "COMP16FL" "COMP24FL"
#>  $ char_prop      :List of 3
#>  $ var_type       :List of 3
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "trt_compliance"
```
