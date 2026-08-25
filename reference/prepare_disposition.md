# Prepare data for treatment compliance table

Prepare data for treatment compliance table

## Usage

``` r
prepare_disposition(
  meta,
  analysis = "disp",
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
meta <- metalite::meta_adam(
  population = metalite_sl_adsl,
  observation = metalite_sl_adsl
) |>
  metalite::define_plan(metalite::plan(
    analysis = "disp",
    population = "apat",
    observation = "apat",
    parameter = "disposition;medical-disposition"
  )) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = SAFFL == "Y"
  ) |>
  metalite::define_parameter(
    name = "disposition",
    var = "EOSSTT",
    label = "Trial Disposition",
    var_lower = "DCSREAS"
  ) |>
  metalite::define_parameter(
    name = "medical-disposition",
    var = "EOTSTT",
    label = "Participant Study Medication Disposition",
    var_lower = "DCTREAS"
  ) |>
  metalite::define_analysis(
    name = "disp",
    title = "Disposition of Participant"
  ) |>
  metalite::meta_build()
#> Warning: disp: has missing label

meta |> prepare_disposition()
#> List of 14
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
```
