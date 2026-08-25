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
meta <- metalite::meta_adam(
  population = metalite_sl_adsl,
  observation = metalite_sl_adsl
) |>
  metalite::define_plan(metalite::plan(
    analysis = "base_char",
    population = "apat",
    observation = "apat",
    parameter = "age;gender;race"
  )) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = SAFFL == "Y"
  ) |>
  metalite::define_parameter(
    name = "age",
    var = "AGE",
    label = "Age (years)",
    vargroup = "AGEGR1"
  ) |>
  metalite::define_parameter(name = "gender", var = "SEX", label = "Gender") |>
  metalite::define_parameter(name = "race", var = "RACE", label = "Race") |>
  metalite::define_analysis(
    name = "base_char",
    title = "Participant Baseline Characteristics by Treatment Group"
  ) |>
  metalite::meta_build()
#> Warning: base_char: has missing label

meta |> prepare_sl_summary(population = "apat", analysis = "base_char")
#> List of 14
#>  $ meta           :List of 7
#>  $ population     : chr "apat"
#>  $ observation    : chr "apat"
#>  $ parameter      : chr "age;gender;race"
#>  $ n              :'data.frame': 1 obs. of  6 variables:
#>  $ order          : NULL
#>  $ group          : chr "TRTA"
#>  $ reference_group: NULL
#>  $ char_n         :List of 3
#>  $ char_var       : chr [1:3] "AGE" "SEX" "RACE"
#>  $ char_prop      :List of 3
#>  $ var_type       :List of 3
#>  $ group_label    : Factor w/ 3 levels "Placebo","Low Dose",..: 1 3 2
#>  $ analysis       : chr "base_char"
```
