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
  sl_plan <- metalite::plan(
    analysis = "disp",
    population = "apat",
    observation = "apat",
    parameter = "disposition;medical-disposition"
  )

  metadata_sl <- metalite::meta_adam(
    observation = metalite_sl_adsl,
    population = metalite_sl_adsl
  ) |>
    metalite::define_plan(sl_plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = SAFFL == "Y"
    ) |>
    metalite::define_parameter(
      name = "disposition",
      var = "EOSSTT",
      label = "Trial Disposition",
      var_lower = "DCSREAS"
    ) |>
    metalite::define_parameter(
      name = "medical-disposition",
      var = "EOTSTT",
      label = "Participant Study Medication Disposition",
      var_lower = "DCTREAS"
    ) |>
    metalite::define_analysis(
      name = "disp",
      title = "Disposition of Participant"
    ) |>
    metalite::meta_build()

  analysis_plan <- metalite::plan(
    analysis = "ae_specific",
    population = "apat",
    observation = "wk12",
    parameter = "any"
  )

  metadata_ae <- metalite::meta_adam(
    observation = metalite_sl_adae,
    population = metalite_sl_adsl
  ) |>
    metalite::define_plan(analysis_plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = SAFFL == "Y",
      label = "All Participants as Treated"
    ) |>
    metalite::define_observation(
      name = "wk12",
      group = "TRTA",
      subset = SAFFL == "Y",
      label = "Weeks 0 to 12"
    ) |>
    metalite::define_parameter(
      name = "any",
      term1 = "",
      term2 = "",
      var = "AEDECOD",
      soc = "AEBODSYS",
      label = "All AEs"
    ) |>
    metalite::define_analysis(
      name = "ae_specific",
      title = "Participants With Adverse Events"
    ) |>
    metalite::meta_build()

  react_disposition(
    metadata_sl = metadata_sl,
    metadata_ae = metadata_ae
  )
}
```
