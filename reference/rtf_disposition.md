# Disposition table

Disposition table

## Usage

``` r
rtf_disposition(
  outdata,
  source,
  col_rel_width = NULL,
  text_font_size = 9,
  orientation = "portrait",
  footnotes = NULL,
  title = NULL,
  path_outdata = NULL,
  path_outtable = NULL
)
```

## Arguments

- outdata:

  An `outdata` object created by
  [`prepare_sl_summary()`](https://merck.github.io/metalite.sl/reference/prepare_sl_summary.md).

- source:

  A character value of the data source.

- col_rel_width:

  Column relative width in a vector e.g. c(2,1,1) refers to 2:1:1.
  Default is NULL for equal column width.

- text_font_size:

  Text font size. To vary text font size by column, use numeric vector
  with length of vector equal to number of columns displayed e.g.
  c(9,20,40).

- orientation:

  Orientation in 'portrait' or 'landscape'.

- footnotes:

  A character vector of table footnotes.

- title:

  Term "analysis", "observation" and "population") for collecting title
  from metadata or a character vector of table titles.

- path_outdata:

  A character string of the outdata path.

- path_outtable:

  A character string of the outtable path.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- metalite::meta_adam(
  population = metalite_sl_adsl,
  observation = metalite_sl_adsl
) |>
  metalite::define_plan(metalite::plan(
    analysis = "disp", population = "apat",
    observation = "apat", parameter = "disposition;medical-disposition"
  )) |>
  metalite::define_population(
    name = "apat", group = "TRTA", subset = SAFFL == "Y"
  ) |>
  metalite::define_parameter(
    name = "disposition", var = "EOSSTT", label = "Trial Disposition",
    var_lower = "DCSREAS"
  ) |>
  metalite::define_parameter(
    name = "medical-disposition", var = "EOTSTT",
    label = "Participant Study Medication Disposition", var_lower = "DCTREAS"
  ) |>
  metalite::define_analysis(
    name = "disp", title = "Disposition of Participant"
  ) |>
  metalite::meta_build()
#> Warning: disp: has missing label

meta |>
  prepare_disposition(population = "apat", parameter = "disposition;medical-disposition") |>
  format_disposition() |>
  rtf_disposition(
    source = "Source: [CDISCpilot: adam-adsl]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = tempfile(fileext = ".rtf")
  )
#> The outdata is saved in/tmp/RtmpOJOx6y/file1a47687346b0.Rdata
#> The output is saved in/tmp/RtmpOJOx6y/file1a476fa5ff90.rtf
```
