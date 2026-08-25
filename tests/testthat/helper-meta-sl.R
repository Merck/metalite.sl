meta_sl_test <- function() {
  adsl <- r2rtf::r2rtf_adsl
  adsl$TRTA <- factor(
    adsl$TRT01A,
    levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
    labels = c("Placebo", "Low Dose", "High Dose")
  )

  adae <- r2rtf::r2rtf_adae
  adaedisc <- subset(
    adae[adae$AEACN == "DRUG WITHDRAWN", ],
    select = c(USUBJID, AEACN)
  )
  adaedisc <- adaedisc[!duplicated(adaedisc), ]

  adsl <- merge(adsl, adaedisc, by = "USUBJID", all.x = TRUE)
  adsl$EOTSTT <- ifelse(adsl$AEACN == "DRUG WITHDRAWN", "Discontinued", NA)
  adsl$DCTREAS <- ifelse(adsl$EOTSTT == "Discontinued", "Adverse Event", NA)
  adsl$EOTSTT[is.na(adsl$EOTSTT)] <- "temp"
  adsl$DCTREAS[is.na(adsl$DCTREAS)] <- "temp"

  adsl[adsl$EOTSTT != "Discontinued", "EOTSTT"] <- sample(
    x = c("Complete", "Discontinued", "Participants Ongoing"),
    size = sum(adsl$EOTSTT != "Discontinued"),
    prob = c(0.6, 0.2, 0.2),
    replace = TRUE
  )
  adsl[
    adsl$EOTSTT == "Discontinued" & adsl$DCTREAS != "Adverse Event",
    "DCTREAS"
  ] <- sample(
    x = c("Withdrawal By Subject", "Lack of Efficacy", "Lost to Follow-Up"),
    size = sum(adsl$EOTSTT == "Discontinued" & adsl$DCTREAS != "Adverse Event"),
    prob = c(0.3, 0.4, 0.3),
    replace = TRUE
  )
  adsl[adsl$EOTSTT != "Discontinued", "DCTREAS"] <- NA
  adsl$EOSSTT <- adsl$EOTSTT
  adsl$DCSREAS <- ifelse(adsl$DCTREAS == "Adverse Event", "Other", adsl$DCTREAS)

  analysis_plan <- metalite::plan(
    analysis = "base_char",
    population = "apat",
    observation = "apat",
    parameter = "age;gender;race"
  ) |>
    metalite::add_plan(
      analysis = "trt_compliance",
      population = "apat",
      observation = "apat",
      parameter = "comp8;comp16;comp24"
    ) |>
    metalite::add_plan(
      analysis = "disp",
      population = "apat",
      observation = "apat",
      parameter = "disposition;medical-disposition"
    ) |>
    metalite::add_plan(
      analysis = "base_char_subgroup",
      population = "apat",
      observation = "apat",
      parameter = "age"
    )

  metalite::meta_adam(population = adsl, observation = adsl) |>
    metalite::define_plan(analysis_plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = SAFFL == "Y"
    ) |>
    metalite::define_parameter(
      name = "age",
      var = "AGE",
      label = "Age (years)",
      vargroup = "AGEGR1"
    ) |>
    metalite::define_parameter(
      name = "gender",
      var = "SEX",
      label = "Gender"
    ) |>
    metalite::define_parameter(
      name = "race",
      var = "RACE",
      label = "Race"
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
    metalite::define_parameter(
      name = "comp8",
      var = "COMP8FL",
      label = "Compliance (Week 8)"
    ) |>
    metalite::define_parameter(
      name = "comp16",
      var = "COMP16FL",
      label = "Compliance (Week 16)"
    ) |>
    metalite::define_parameter(
      name = "comp24",
      var = "COMP24FL",
      label = "Compliance (Week 24)"
    ) |>
    metalite::define_analysis(
      name = "base_char",
      title = "Participant Baseline Characteristics by Treatment Group",
      label = "baseline characteristic table"
    ) |>
    metalite::define_analysis(
      name = "trt_compliance",
      title = "Summary of Treatment Compliance",
      label = "treatment compliance table"
    ) |>
    metalite::define_analysis(
      name = "disp",
      title = "Disposition of Participant",
      label = "disposition table"
    ) |>
    metalite::define_analysis(
      name = "base_char_subgroup",
      title = "Participant by Age Category and Sex",
      label = "baseline characteristic sub group table"
    ) |>
    metalite::meta_build()
}
