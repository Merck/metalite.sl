# metalite.sl <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

<!-- badges: end -->

## Overview

R package designed for the analysis & reporting of subject baseline characteristics in clinical trials.
We assume ADaM datasets are ready for analysis and
leverage [metalite](https://merck.github.io/metalite/) data structure to define
inputs and outputs.

## Workflow

The general workflow is:

1. Define metadata information using metalite.
2. `prepare_base_char()` prepares datasets for summary of baseline characteristics.
3. `format_base_char()` formats output layout.
4. `rtf_base_char()` creates TLFs.

Here is a quick example

```r
library("metalite.sl")

meta_sl_example() |>
  prepare_base_char(
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
  - For example, define analysis population once to use in all adverse events analysis.
- Consistent input and output in standard functions.
- Streamlines mock table generation.
