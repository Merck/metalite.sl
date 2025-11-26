# Prepare data for baseline characteristic table

Prepare data for baseline characteristic table

## Usage

``` r
prepare_sl_summary(
  meta,
  population,
  analysis,
  parameter = paste(names(meta$parameter), collapse = ";")
)
```

## Arguments

- meta:

  A metadata object created by metalite.

- population:

  A character value of population term name. The term name is used as
  key to link information.

- analysis:

  A character value of analysis term name. The term name is used as key
  to link information.

- parameter:

  A character value of parameter term name. The term name is used as key
  to link information.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- meta_sl_example()
meta |> prepare_sl_summary(population = "apat", analysis = "base_char")
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age;gender;race;disposition;medical-disposition;comp8;comp16;comp24"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 8
#>  $ char_var       : chr [1:8] "AGE" "SEX" "RACE" "EOSSTT" ...
#>  $ char_prop      :List of 8
#>  $ var_type       :List of 8
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "base_char"
```
