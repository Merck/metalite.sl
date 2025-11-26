# Display interactive disposition tables with AE subgroup analysis

Display interactive disposition tables with AE subgroup analysis

## Usage

``` r
react_disposition(
  metadata_sl,
  metadata_ae,
  analysis = "disp",
  trtvar = metalite::collect_adam_mapping(metadata_sl, population)$group,
  population = metadata_sl$plan$population[metadata_sl$plan$analysis == analysis],
  sl_parameter = paste(metadata_sl$plan$parameter[metadata_sl$plan$analysis == analysis],
    collapse = ";"),
  sl_col_selected = c("siteid", "subjid", "sex", "age", "weightbl"),
  sl_col_names = c("Site", "Subject ID", "Sex", "Age (Year)", "Weight (kg)"),
  ae_observation = "wk12",
  ae_population = population,
  ae_parameter = "any",
  ae_col_selected = c("AESOC", "ASTDT", "AENDT", "AETERM", "duration", "AESEV", "AESER",
    "related", "AEACN", "AEOUT"),
  ae_col_names = c("SOC", "Onset Date", "End Date", "AE", "Duraion", "Intensity",
    "Serious", "Related", "Action Taken", "Outcome"),
  display_total = TRUE,
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

- analysis:

  The analysis label provided in `metadata_sl`.

- trtvar:

  A character that indicate variable for the treatment group.

- population:

  A character value of population term name. The term name is used as
  key to link information.

- sl_parameter:

  A character value of parameter term name for the baseline
  characteristic table. The term name is used as key to link
  information.

- sl_col_selected:

  A character vector of variable which will be shown in the participant
  detail.

- sl_col_names:

  A character vector for the columns names of the participant detail.
  Same length as sl_col_selected.

- ae_observation:

  The meta parameter of the observation in adverse event listing.

- ae_population:

  The meta parameter of the population in adverse event listing.

- ae_parameter:

  A character value of the parameter in adverse event listing.

- ae_col_selected:

  A character vector of variable which will be shown in the AE detail.

- ae_col_names:

  A character vector for the columns names of the AE detail. Same length
  as ae_col_selected.

- display_total:

  Display total column or not.

- width:

  A numeric value of width of the table in pixels.

## Value

An reactable combing both baseline characteristic table and AE subgroup
specific tables.

## Examples

``` r
if (interactive()) {
  react_disposition(
    metadata_sl = meta_sl_example(),
    metadata_ae = metalite.ae::meta_ae_example()
  )
}
```
