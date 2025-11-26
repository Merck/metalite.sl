# Build an Interactive Baseline Characteristic Table

``` r
library(r2rtf)
library(metalite)
library(metalite.ae)
library(metalite.sl)
```

There are 2 key metadata types:

- metadata for the baseline characteristic table
- metadata for the AE subgroup specific table

## Build metadata

### Metadata for baseline characteristic table

The code below is the same as
[`meta_sl_example()`](https://merck.github.io/metalite.sl/reference/meta_sl_example.md).

``` r
adsl <- r2rtf::r2rtf_adsl
adsl$TRTA <- adsl$TRT01A
adsl$TRTA <- factor(adsl$TRTA,
  levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
  labels = c("Placebo", "Low Dose", "High Dose")
)

meta_sl <- meta_adam(
  population = adsl,
  observation = adsl
) |>
  define_plan(plan = plan(
    analysis = "base_char", population = "apat",
    observation = "apat", parameter = "age;gender;race"
  )) |>
  define_population(
    name = "apat",
    group = "TRTA",
    subset = quote(SAFFL == "Y"),
    var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE")
  ) |>
  define_observation(
    name = "apat",
    group = "TRTA",
    subset = quote(SAFFL == "Y"),
    var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE")
  ) |>
  define_parameter(
    name = "age",
    var = "AGE",
    label = "Age (years)",
    vargroup = "AGEGR1"
  ) |>
  define_parameter(
    name = "gender",
    var = "SEX",
    label = "Gender"
  ) |>
  define_parameter(
    name = "race",
    var = "RACE",
    label = "Race"
  ) |>
  define_analysis(
    name = "base_char",
    title = "Participant Baseline Characteristics by Treatment Group",
    label = "baseline characteristic table"
  ) |>
  meta_build()
```

### A metadata of the AE subgroup specific analysis

In this vignette, we will directly use the metadata built by
[`meta_ae_example()`](https://merck.github.io/metalite.ae/reference/meta_ae_example.html).

``` r
meta_ae <- meta_ae_example()
```

### Customization (Optional)

If you want to capitalize only the first letter of “RACE” (e.g., Black
or african american) or any other character variable, you can customize
the `react_base_char` function at the beginning of the code.

``` r
# function to capitalize the first letter of a string that has multiple words
capitalize_words <- function(x) {
  sapply(x, function(word) {
    paste0(toupper(substr(word, 1, 1)), tolower(substr(word, 2, nchar(word))))
  })
}
```

``` r
# 1) In "data_population": extract the RACE values as a character vector
race_values_pop <- meta_sl[["data_population"]]$RACE # Use $ to get a vector

# Capitalize the race values
meta_sl[["data_population"]]$RACE <- capitalize_words(race_values_pop) # Assign back as a vector

# 2) In "data_observation": extract the RACE values as a character vector
race_values_obs <- meta_sl[["data_observation"]]$RACE # Use $ to get a vector

# Capitalize the race values
meta_sl[["data_observation"]]$RACE <- capitalize_words(race_values_obs) # Assign back as a vector
```

## Build a reactable

### Baseline characteristic table + Participants With Drug-Related AE

``` r
react_base_char(
  metadata_sl = meta_sl,
  metadata_ae = meta_ae,
  ae_subgroup = c("age", "race", "gender"),
  ae_specific = "rel",
  width = 1200
)
```

### Baseline characteristic table + Participants With Serious AE

``` r
react_base_char(
  metadata_sl = meta_sl,
  metadata_ae = meta_ae,
  ae_subgroup = c("age", "race", "gender"),
  ae_specific = "ser",
  width = 1200
)
```
