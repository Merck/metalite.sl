meta_sl_exposure_test <- function() {
  adsl <- r2rtf::r2rtf_adsl

  set.seed(123)

  adexsum <- data.frame(USUBJID = adsl$USUBJID)
  adexsum$TRTA <- factor(
    adsl$TRT01A,
    levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
    labels = c("Placebo", "Low Dose", "High Dose")
  )
  adexsum$APERIODC <- "Base"
  adexsum$APERIOD <- 1
  adexsum$AVAL <- sample(
    x = seq_len(24 * 7),
    size = length(adexsum$USUBJID),
    replace = TRUE
  )
  adexsum$EXDURGR[adexsum$AVAL >= 1] <- ">=1 day and <7 days"
  adexsum$EXDURGR[adexsum$AVAL >= 7] <- ">=7 days and <28 days"
  adexsum$EXDURGR[adexsum$AVAL >= 28] <- ">=28 days and <12 weeks"
  adexsum$EXDURGR[adexsum$AVAL >= 12 * 7] <- ">=12 weeks and <24 weeks"
  adexsum$EXDURGR[adexsum$AVAL >= 24 * 7] <- ">=24 weeks"
  adexsum$EXDURGR <- factor(
    adexsum$EXDURGR,
    levels = c(
      ">=1 day and <7 days", ">=7 days and <28 days",
      ">=28 days and <12 weeks", ">=12 weeks and <24 weeks", ">=24 weeks"
    )
  )

  analysis_plan <- metalite::plan(
    analysis = "exp_dur",
    population = "apat",
    observation = "apat",
    parameter = "expdur"
  )

  metalite::meta_adam(population = adexsum, observation = adexsum) |>
    metalite::define_plan(analysis_plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = APERIOD == 1 & AVAL > 0
    ) |>
    metalite::define_parameter(
      name = "expdur",
      var = "AVAL",
      label = "Exposure Duration (Days)",
      vargroup = "EXDURGR"
    ) |>
    metalite::define_analysis(
      name = "exp_dur",
      title = "Summary of Exposure Duration",
      label = "exposure duration table"
    ) |>
    metalite::meta_build()
}