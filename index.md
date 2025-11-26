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

meta_sl_example() |>
  prepare_sl_summary(
    population = "apat",
    observation = "apat",
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
