# Prepare data for treatment compliance table

Prepare data for treatment compliance table

## Usage

``` r
prepare_base_char_subgroup(
  meta,
  population,
  analysis = "base_char_subgroup",
  parameter,
  subgroup_var,
  subgroup_header = c(meta$population[[population]]$group, subgroup_var)
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

- subgroup_var:

  A character value of subgroup variable name in observation data saved
  in `meta$data_observation`.

- subgroup_header:

  A character vector for column header hierarchy. The first element will
  be the first level header and the second element will be second level
  header.

## Value

A list of analysis raw datasets.

## Examples

``` r
meta <- meta_sl_example()
outdata <- prepare_base_char_subgroup(
  meta,
  population = "apat",
  parameter = "age",
  subgroup_var = "TRTA",
  subgroup_header = c("SEX", "TRTA")
)
```
