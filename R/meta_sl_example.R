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

  meta <- metalite::meta_adam(
    population = adsl,
    observation = adsl
  ) |>
    metalite::define_plan(plan = metalite::plan(
      analysis = "base_char", population = "apat",
      observation = "apat", parameter = "age;gender;race"
    )) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE")
    ) |>
    metalite::define_observation(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      var = c("USUBJID", "TRTA", "SAFFL", "AGEGR1", "SEX", "RACE")
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
    metalite::define_analysis(
      name = "base_char",
      title = "Participant Baseline Characteristics by Treatment Group",
      label = "baseline characteristic table",
      var_name = c("AGEGR1", "SEX")
    ) |>
    metalite::meta_build()
}
