# Exposure duration table

Exposure duration table

## Usage

``` r
rtf_exp_duration(
  outdata,
  source = "Source: [CDISCpilot: adam-adsl; adex]",
  col_rel_width = NULL,
  text_font_size = 9,
  orientation = "portrait",
  footnotes =
    c("Each participant is counted once on each applicable duration category row.",
    "Duration of Exposure is the time from the first dose date to the last dose date."),
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

RTF file and source dataset for baseline characteristic table.

## Examples

``` r
meta <- meta_sl_exposure_example()

meta |>
  prepare_exp_duration(population = "apat", parameter = "expdur") |>
  format_exp_duration(display_col = c("n", "prop", "total")) |>
  rtf_exp_duration(
    source = "Source: [CDISCpilot: adam-adsl; adex]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = tempfile(fileext = ".rtf")
  )
#> The outdata is saved in/tmp/RtmpN9Qkf0/file1b0a778dbc74.Rdata
#> The output is saved in/tmp/RtmpN9Qkf0/file1b0a76d0c3ab.rtf
```
