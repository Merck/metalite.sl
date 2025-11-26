# Display interactive baseline characteristic tables with AE subgroup analysis

Display interactive baseline characteristic tables with AE subgroup
analysis

## Usage

``` r
react_base_char(
  metadata_sl,
  metadata_ae,
  population = "apat",
  observation = "wk12",
  display_total = TRUE,
  sl_parameter = "age;gender;race",
  ae_subgroup = c("gender", "race"),
  ae_specific = "rel",
  width = 1200
)
```

## Arguments

- metadata_sl:

  A metadata created by metalite, which builds the baseline
  characteristic table

- metadata_ae:

  A metadata created by metalite, which builds the AE subgroup specific
  table

- population:

  A character value of population term name. The term name is used as
  key to link information.

- observation:

  A character value of observation term name. The term name is used as
  key to link information.

- display_total:

  Display total column or not.

- sl_parameter:

  A character value of parameter term name for the baseline
  characteristic table. The term name is used as key to link
  information.

- ae_subgroup:

  A vector of strubf to specify the subgroups in the AE subgroup
  specific table.

- ae_specific:

  A string specifying the AE specific category.

- width:

  A numeric value of width of the table in pixels.

## Value

An reactable combing both baseline characteristic table and AE subgroup
specific tables.

## Examples

``` r
if (interactive()) {
  react_base_char(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example(),
    population = "apat",
    observation = "wk12",
    display_total = TRUE,
    sl_parameter = "age;gender;race",
    ae_subgroup = c("age", "race", "gender"),
    ae_specific = "rel",
    width = 1200
  )
}
```
