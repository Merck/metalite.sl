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
  
  # Create a variable EOSSTT indicating the end of end of study status
  adsl$EOSSTT <- sample(x = c("Participants Ongoing", "Discontinued"),
                        size = length(adsl$USUBJID), 
                        prob = c(0.8, 0.2), replace = TRUE)
  adsl[adsl[["EOSSTT"]] == "Discontinued", "DCSREAS"] <- sample(x = c("Adverse Event", "I/E Not Met", "Withdrew Consent", "Lack of Efficacy"),
                                                                size = length(adsl[adsl[["EOSSTT"]] == "Discontinued", "USUBJID"]), 
                                                                prob = c(0.7, 0.1, 0.1, 0.1), replace = TRUE)
  # Create a variable EOTSTT1 indicating the end of treatment status part 1
  adsl$EOTSTT1 <- sample(x = c("Completed", "Discontinued"),
                         size = length(adsl$USUBJID), 
                         prob = c(0.85, 0.15), replace = TRUE)
  adsl[adsl[["EOTSTT1"]] == "Discontinued", "DCTREAS"] <- sample(x = c("Adverse Event", "Lack of Efficacy"),
                                                                size = length(adsl[adsl[["EOTSTT1"]] == "Discontinued", "USUBJID"]), 
                                                                prob = c(0.9, 0.1), replace = TRUE)
  
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
    )
    
  meta <- metalite::meta_adam(
    population = adsl,
    observation = adsl
  ) |>
    metalite::define_plan(plan) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE", "EOSSTT", "EOTSTT1", "DCSREAS", "DCTREAS", "COMP8FL", "COMP16FL", "COMP24FL")
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
      var = "EOTSTT1",
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
  
  # Create ADEXSUM dataset
  adexsum <- data.frame(USUBJID=adsl$USUBJID)
  adexsum$TRTA <- factor(adsl$TRT01A,
                         levels = c("Placebo", "Xanomeline Low Dose", "Xanomeline High Dose"),
                         labels = c("Placebo", "Low Dose", "High Dose")
  )
  
  adexsum$APERIODC <- "Base"
  adexsum$APERIOD <- 1
  adexsum$AVAL <- sample(x = 0:(24*7), size = length(adexsum$USUBJID), replace = TRUE)
  adexsum$EXDURGR <- "not treated"
  adexsum$EXDURGR[adexsum$AVAL>=1] <- ">=1 day"
  adexsum$EXDURGR[adexsum$AVAL>=7] <- ">=7 days"
  adexsum$EXDURGR[adexsum$AVAL>=28] <- ">=28 days"
  adexsum$EXDURGR[adexsum$AVAL>=12*7] <- ">=12 weeks"
  adexsum$EXDURGR[adexsum$AVAL>=24*7] <- ">=24 weeks"
  
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
      subset = quote(APERIOD==1 & AVAL>0),
      var = c("USUBJID", "TRTA", "EXDURGR", "AVAL"),
    ) |>
    metalite::define_parameter(
      name = "expdur",
      var = "AVAL",
      label = "Exposure Duration (Days)",
      vargroup = "EXDURGR"
    )|>
    metalite::define_analysis(
      name = "exp_dur",
      title = "Summary of Exposure Duration",
      label = "exposure duration table"
    ) |>
    metalite::meta_build()
}