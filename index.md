# metalite.sl

## Overview

R package designed for the analysis & reporting of subject baseline
characteristics in clinical trials. We assume ADaM datasets are ready
for analysis and leverage [metalite](https://merck.github.io/metalite/)
data structure to define inputs and outputs.

## Workflow

The general workflow is:

1.  Define metadata information using metalite.
2.  [`prepare_sl_summary()`](https://merck.github.io/metalite.sl/reference/prepare_sl_summary.md)
    prepares datasets for summary of baseline characteristics.
3.  [`format_base_char()`](https://merck.github.io/metalite.sl/reference/format_base_char.md)
    formats output layout.
4.  [`rtf_base_char()`](https://merck.github.io/metalite.sl/reference/rtf_base_char.md)
    creates TLFs.

Here is a quick example

``` r

library("metalite.sl")

metadata_sl <- metalite::meta_adam(
  population = metalite_sl_adsl,
  observation = metalite_sl_adsl
) |>
  metalite::define_plan(metalite::plan(
    analysis = "base_char",
    population = "apat",
    observation = "apat",
    parameter = "age;gender"
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
  metalite::define_parameter(
    name = "gender",
    var = "SEX",
    label = "Gender"
  ) |>
  metalite::define_analysis(
    name = "base_char",
    title = "Participant Baseline Characteristics by Treatment Group"
  ) |>
  metalite::meta_build()

metadata_sl |>
  prepare_sl_summary(
    population = "apat",
    analysis = "base_char",
    parameter = "age;gender"
  ) |>
  format_base_char() |>
  rtf_base_char(
    source = "Source: [CDISCpilot: adam-adsl]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = tempfile(fileext = ".rtf")
  )
```

## Highlighted features

- Avoid duplicated input by using metadata structure.
  - For example, define analysis population once to use in all adverse
    events analysis.
- Consistent input and output in standard functions.
- Streamlines mock table generation.
