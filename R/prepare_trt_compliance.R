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

#' Prepare data for treatment compliance table
#'
#' @param meta A metadata object created by metalite.
#' @param population A character value of population term name.
#'   The term name is used as key to link information.
#' @param analysis A character value of analysis term name.
#'   The term name is used as key to link information.
#' @param parameter A character value of parameter term name.
#'   The term name is used as key to link information.
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- metalite::meta_adam(
#'   population = metalite_sl_adsl,
#'   observation = metalite_sl_adsl
#' ) |>
#'   metalite::define_plan(metalite::plan(
#'     analysis = "trt_compliance",
#'     population = "apat",
#'     observation = "apat",
#'     parameter = "comp8;comp16;comp24"
#'   )) |>
#'   metalite::define_population(
#'     name = "apat",
#'     group = "TRTA",
#'     subset = SAFFL == "Y"
#'   ) |>
#'   metalite::define_parameter(
#'     name = "comp8",
#'     var = "COMP8FL",
#'     label = "Compliance (Week 8)"
#'   ) |>
#'   metalite::define_parameter(
#'     name = "comp16",
#'     var = "COMP16FL",
#'     label = "Compliance (Week 16)"
#'   ) |>
#'   metalite::define_parameter(
#'     name = "comp24",
#'     var = "COMP24FL",
#'     label = "Compliance (Week 24)"
#'   ) |>
#'   metalite::define_analysis(
#'     name = "trt_compliance",
#'     title = "Summary of Treatment Compliance"
#'   ) |>
#'   metalite::meta_build()
#'
#' meta |> prepare_trt_compliance()
prepare_trt_compliance <- function(meta,
                                   analysis = "trt_compliance",
                                   population = meta$plan[meta$plan$analysis == analysis, ]$population,
                                   parameter = paste(meta$plan[meta$plan$analysis == analysis, ]$parameter, collapse = ";")) {
  return(
    prepare_sl_summary(meta,
      analysis = analysis,
      population = population,
      parameter = parameter
    )
  )
}
