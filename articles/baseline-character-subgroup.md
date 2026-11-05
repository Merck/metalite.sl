# Baseline Characteristic Table for Subgroup Analysis

``` r

library(metalite)
library(metalite.sl)
```

## Create Baseline Characteristic Table for Subgroup Analysis

The baseline characteristic subgroup analysis aims to provide tables to
summarize details of participants by subgroup. The development of
baseline characteristic subgroup analysis involves functions:

- [`prepare_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/prepare_base_char_subgroup.md):
  prepare analysis raw datasets.
- [`format_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/format_base_char_subgroup.md):
  prepare analysis outdata with proper format.
- [`rtf_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/rtf_base_char_subgroup.md):
  transfer output dataset to RTF table.

### Build a metadata

``` r

adsl <- r2rtf::r2rtf_adsl
adsl$TRTA <- adsl$TRT01A
adsl$TRTA <- factor(
  adsl$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

plan <- plan(
  analysis = "base_char_subgroup",
  population = "apat",
  observation = "apat",
  parameter = "age;gender;race"
)

meta <- meta_adam(
  population = adsl,
  observation = adsl
) |>
  define_plan(plan = plan) |>
  define_population(
    name = "apat",
    group = "TRTA",
    subset = quote(SAFFL == "Y"),
    var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE")
  ) |>
  metalite::define_parameter(
    name = "age",
    var = "AGE",
    vargroup = "AGEGR1",
    label = attr(adsl$AGE, "label")
  ) |>
  metalite::define_parameter(
    name = "gender",
    var = "SEX",
    label = attr(adsl$SEX, "label")
  ) |>
  metalite::define_parameter(
    name = "race",
    var = "RACE",
    label = attr(adsl$RACE, "label")
  ) |>
  define_analysis(
    name = "base_char_subgroup",
    title = "Participant by Age Category and Sex",
    label = "baseline characteristic sub group table"
  ) |>
  meta_build()
```

### Generate the static baseline characteristic table for subgroup analysis

[`prepare_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/prepare_base_char_subgroup.md)
uses the definitions in `meta` to calculate the summary results.
[`format_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/format_base_char_subgroup.md)
formats those results, and
[`rtf_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/rtf_base_char_subgroup.md)
creates the RTF table.

``` r

outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age;race",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA")
) |>
  format_base_char_subgroup() |>
  rtf_base_char_subgroup(
    source = "Source:  [CDISCpilot: adam-adsl]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = "outtable/base0charsubgroup.rtf"
  )
```

    ## The outdata is saved in/tmp/Rtmpqn59iz/file1beb2498ac4e.Rdata

    ## The output is saved in/home/runner/work/metalite.sl/metalite.sl/vignettes/outtable/base0charsubgroup.rtf
