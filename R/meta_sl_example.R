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
#' @param type A character value specifying the type of meta example.
#'   "char": meta for baseline characteristic table.
#'   "comp": meta for treatment compliance table.
#' 
#' @return A metadata object.
#'
#' @export
#'
#' @examples
#' meta_sl_example()

meta_sl_example <- function( type = c('char', 'comp')[1]) {
  if (type=='char') return(meta_sl_example_char())
  if (type=='comp') return(meta_sl_example_comp())
}

meta_sl_example_char <- function() {
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
      analysis = "base_char", 
      population = "apr",
      observation = "apr", 
      parameter = "age;gender;race"
    )) |>
    metalite::define_population(
      name = "apr",
      group = "TRTA",
      subset = quote(ITTFL == "Y"),
      label = "All Participants Randomized"
    ) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      label = "All Participants as Treated"
    ) |>
    metalite::define_observation(
      name = "apr",
      group = "TRTA",
      subset = quote(ITTFL == "Y"),
      label = "All Participants Randomized"
    ) |>
    metalite::define_observation(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      label = "All Participants as Treated"
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
      label = "baseline characteristic table"
      #var_name = c("AGEGR1", "SEX")
    ) |>
    metalite::meta_build()
}

meta_sl_example_comp <- function(){
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
      analysis = "trt_compliance", population = "apat",
      observation = "apat", parameter = "comp8;comp16;comp24"
    )) |>
    metalite::define_population(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      label = "All Participants as Treated"
    ) |>
    metalite::define_observation(
      name = "apat",
      group = "TRTA",
      subset = quote(SAFFL == "Y"),
      label = "All Participants as Treated"
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
      name = "trt_compliance",
      title = "Summary of Treatment Compliance",
      label = "treatment compliance table"
    ) |>
    metalite::meta_build()
}
