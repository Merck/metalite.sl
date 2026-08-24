meta_ae_sl_example <- function() {
  analysis_plan <- metalite::plan(
    analysis = "ae_specific",
    population = "apat",
    observation = "wk12",
    parameter = "any;rel"
  )

  metalite::meta_adam(
    observation = metalite_sl_adae,
    population = metalite_sl_adsl
  ) |>
    metalite::define_plan(analysis_plan) |>
    metalite::define_population(
      name = "apat",
      var = c(
        "USUBJID", "SAFFL", "TRTA", "TRTDUR",
        "SITEID", "SEX", "RACE", "AGE"
      ),
      group = "TRTA",
      subset = SAFFL == "Y",
      label = "All Participants as Treated"
    ) |>
    metalite::define_observation(
      name = "wk12",
      var = c(
        "USUBJID", "SAFFL", "TRTA", "SEX", "AEDECOD", "AEBODSYS", "AEREL",
        "AESER", "AEOUT", "AEACN", "AESDTH", "ASTDT", "AENDT"
      ),
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
    metalite::define_parameter(
      name = "rel",
      term1 = "Drug-Related",
      term2 = "",
      subset = AEREL %in% c("POSSIBLE", "PROBABLE"),
      var = "AEDECOD",
      soc = "AEBODSYS",
      label = "Drug-related AEs"
    ) |>
    metalite::define_analysis(
      name = "ae_specific",
      title = "Participants With Drug-Related Adverse Events"
    ) |>
    metalite::meta_build()
}