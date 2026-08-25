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
meta <- metalite::meta_adam(
  population = metalite_sl_adsl,
  observation = metalite_sl_adsl
) |>
  metalite::define_plan(metalite::plan(
    analysis = "trt_compliance",
    population = "apat",
    observation = "apat",
    parameter = "comp8;comp16;comp24"
  )) |>
  metalite::define_population(
    name = "apat",
    group = "TRTA",
    subset = SAFFL == "Y"
  ) |>
  metalite::define_parameter(
    name = "comp8",
    var = "COMP8FL",
    label = "Compliance (Week 8)"
  ) |>
  metalite::define_parameter(
    name = "comp16",
    var = "COMP16FL",
    label = "Compliance (Week 16)"
  ) |>
  metalite::define_parameter(
    name = "comp24",
    var = "COMP24FL",
    label = "Compliance (Week 24)"
  ) |>
  metalite::define_analysis(
    name = "trt_compliance",
    title = "Summary of Treatment Compliance"
  ) |>
  metalite::meta_build()
#> Warning: trt_compliance: has missing label

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
