# Subgroup Analysis for Baseline Characteristic

Subgroup Analysis for Baseline Characteristic

## Usage

``` r
rtf_base_char_subgroup(
  outdata,
  source,
  col_rel_width = NULL,
  text_font_size = 8,
  orientation = "landscape",
  footnotes = NULL,
  title = NULL,
  path_outdata = NULL,
  path_outtable = NULL
)
```

## Arguments

- outdata:

  An `outdata` object created by
  [`prepare_base_char_subgroup()`](https://merck.github.io/metalite.sl/reference/prepare_base_char_subgroup.md)

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
# \donttest{
meta <- meta_sl_example()

outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA")
)

outdata |>
  format_base_char_subgroup() |>
  rtf_base_char_subgroup(
    source = "Source:  [CDISCpilot: adam-adsl]",
    path_outdata = tempfile(fileext = ".Rdata"),
    path_outtable = tempfile(fileext = ".rtf")
  )
#> The outdata is saved in/tmp/Rtmplbkbyy/file19047d294050.Rdata
#> The output is saved in/tmp/Rtmplbkbyy/file19044a0658b.rtf
# }
```
