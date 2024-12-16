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
#' @param observation A character value of observation term name.
#'   The term name is used as key to link information.
#' @param analysis A character value of analysis term name.
#'   The term name is used as key to link information.
#' @param parameter A character value of parameter term name.
#'   The term name is used as key to link information.
#' @param display_total A logic value of displaying the total group.
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
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
