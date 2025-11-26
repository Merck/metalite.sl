# Prepare data for exposure duration table

Prepare data for exposure duration table

## Usage

``` r
prepare_exp_duration(
  meta,
  analysis = "exp_dur",
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
meta <- meta_sl_exposure_example()
meta |> prepare_exp_duration()
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "expdur"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 1
#>  $ char_var       : chr "AVAL"
#>  $ char_prop      :List of 1
#>  $ var_type       :List of 1
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "exp_dur"
```
