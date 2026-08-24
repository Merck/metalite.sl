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
#'     analysis = "disp",
#'     population = "apat",
#'     observation = "apat",
#'     parameter = "disposition;medical-disposition"
#'   )) |>
#'   metalite::define_population(
#'     name = "apat",
#'     group = "TRTA",
#'     subset = SAFFL == "Y"
#'   ) |>
#'   metalite::define_parameter(
#'     name = "disposition",
#'     var = "EOSSTT",
#'     label = "Trial Disposition",
#'     var_lower = "DCSREAS"
#'   ) |>
#'   metalite::define_parameter(
#'     name = "medical-disposition",
#'     var = "EOTSTT",
#'     label = "Participant Study Medication Disposition",
#'     var_lower = "DCTREAS"
#'   ) |>
#'   metalite::define_analysis(
#'     name = "disp",
#'     title = "Disposition of Participant"
#'   ) |>
#'   metalite::meta_build()
#'
#' meta |> prepare_disposition()
prepare_disposition <- function(meta,
                                analysis = "disp",
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
