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
