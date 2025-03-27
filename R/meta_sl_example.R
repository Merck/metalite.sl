# Copyright (c) 2024 Merck & Co., Inc., Rahway, NJ, USA and its affiliates.
# All rights reserved.
#
# This file is part of the metalite.sl program.
#
# metalite.sl is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#' Create an example `meta_sl_example` object
#'
#' This function is only for illustration purpose.
#' r2rtf is required.
#'
#' @return A metadata object.
#'
#' @export
#'
#' @examples
#' meta_sl_example()
meta_sl_example <- function() {
  adsl <- r2rtf::r2rtf_adsl
  adsl$TRTA <- adsl$TRT01A
  adsl$TRTA <- factor(adsl$TRTA,
    levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
    labels = c("Placebo", "Low Dose", "High Dose")
  )

  set.seed(123)

  # Create a variable EOSSTT indicating the end of end of study status
  adae <- metalite.ae::meta_ae_example()$data_observation

  # adae$AEACN <- sample(
  #  x = c("DOSE NOT CHANGED", "DRUG INTERRUPTED", "DRUG WITHDRAWN", "NOT APPLICABLE", "UNKNOWN"),
  #  size = length(adae$USUBJID),
  #  prob = c(0.7, 0.1,0.05,0.1,0.05), replace = TRUE
  # )

  # Treatment Disposition
  # For discontinued due to AE
  adaedisc <- subset(adae[which(adae$AEACN == "DRUG WITHDRAWN"), ], select = c(USUBJID, AEACN))
  adaedisc <- adaedisc[!duplicated(adaedisc), ]

  adsl <- merge(adsl, adaedisc, by = "USUBJID", all.x = TRUE)
  adsl$EOTSTT <- ifelse(adsl$AEACN == "DRUG WITHDRAWN", "Discontinued", NA)
  adsl$DCTREAS <- ifelse(adsl$EOTSTT == "Discontinued", "Adverse Event", NA)

  # sample assignment cannot be NA value
  adsl$EOTSTT[is.na(adsl$EOTSTT)] <- "temp"
  adsl$DCTREAS[is.na(adsl$DCTREAS)] <- "temp"


  adsl[adsl$EOTSTT != "Discontinued", "EOTSTT"] <- sample(
    x = c("Complete", "Discontinued", "Participants Ongoing"),
    size = length(adsl[adsl[["EOTSTT"]] != "Discontinued", "USUBJID"]),
    prob = c(0.6, 0.2, 0.2), replace = TRUE
  )

  adsl[adsl$EOTSTT == "Discontinued" & adsl$DCTREAS != "Adverse Event", "DCTREAS"] <- sample(
    x = c("Withdrawal By Subject", "Lack of Efficacy", "Lost to Follow-Up"),
    size = length(adsl[adsl$EOTSTT == "Discontinued" & adsl$DCTREAS != "Adverse Event", "USUBJID"]),
    prob = c(0.3, 0.4, 0.3), replace = TRUE
  )

  adsl[adsl[["EOTSTT"]] != "Discontinued", "DCTREAS"] <- NA

  # Trial Disposition
  adsl$EOSSTT <- adsl$EOTSTT
  adsl$DCSREAS <- adsl$DCTREAS

  adsl$DCSREAS <- ifelse(adsl$DCSREAS == "Adverse Event", "Other", adsl$DCTREAS)

  plan <- metalite::plan(
    analysis = "base_char", population = "apat",
    observation = "apat", parameter = "age;gender;race"
  ) |>
    metalite::add_plan(
      analysis = "trt_compliance", population = "apat",
      observation = "apat", parameter = "comp8;comp16;comp24"
    ) |>
    metalite::add_plan(
      analysis = "disp", population = "apat",
      observation = "apat", parameter = "disposition;medical-disposition"
    ) |>
    metalite::add_plan(
      analysis = "base_char_subgroup", population = "apat",
      observation = "apat", parameter = "age"
    )

  meta <- metalite::meta_adam(
    population = adsl,
    observation = adsl
  ) |>
    metalite::define_plan(plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y")
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
      label = "Compliance (Week 8)",
    ) |>
    metalite::define_parameter(
      name = "comp16",
      var = "COMP16FL",
      label = "Compliance (Week 16)",
    ) |>
    metalite::define_parameter(
      name = "comp24",
      var = "COMP24FL",
      label = "Compliance (Week 24)",
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

#' Create an example `meta_sl_exposure_example` object
#'
#' This function is only for illustration purpose.
#' r2rtf is required.
#'
#' @return A metadata object.
#'
#' @export
#'
#' @examples
#' meta_sl_exposure_example()
meta_sl_exposure_example <- function() {
  adsl <- r2rtf::r2rtf_adsl

  set.seed(123)

  # Create ADEXSUM dataset
  adexsum <- data.frame(USUBJID = adsl$USUBJID)
  adexsum$TRTA <- factor(adsl$TRT01A,
    levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
    labels = c("Placebo", "Low Dose", "High Dose")
  )

  adexsum$APERIODC <- "Base"
  adexsum$APERIOD <- 1

  adexsum$AVAL <- sample(x = 1:(24 * 7), size = length(adexsum$USUBJID), replace = TRUE)
  adexsum$EXDURGR[adexsum$AVAL >= 1] <- ">=1 day and <7 days"
  adexsum$EXDURGR[adexsum$AVAL >= 7] <- ">=7 days and <28 days"
  adexsum$EXDURGR[adexsum$AVAL >= 28] <- ">=28 days and <12 weeks"
  adexsum$EXDURGR[adexsum$AVAL >= 12 * 7] <- ">=12 weeks and <24 weeks"
  adexsum$EXDURGR[adexsum$AVAL >= 24 * 7] <- ">=24 weeks"

  adexsum$EXDURGR <- factor(adexsum$EXDURGR,
    levels = c(">=1 day and <7 days", ">=7 days and <28 days", ">=28 days and <12 weeks", ">=12 weeks and <24 weeks", ">=24 weeks")
  )

  plan <- metalite::plan(
    analysis = "exp_dur", population = "apat",
    observation = "apat", parameter = "expdur"
  )

  meta <- metalite::meta_adam(
    population = adexsum,
    observation = adexsum
  ) |>
    metalite::define_plan(plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = quote(APERIOD == 1 & AVAL > 0)
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
