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

#' Exposure duration table
#'
#' @param outdata An `outdata` object created by [prepare_sl_summary()].
#' @param source A character value of the data source.
#' @inheritParams r2rtf::rtf_page
#' @inheritParams r2rtf::rtf_body
#' @param footnotes A character vector of table footnotes.
#' @param title Term "analysis", "observation" and "population") for collecting title from metadata or a character vector of table titles.
#' @param path_outdata A character string of the outdata path.
#' @param path_outtable A character string of the outtable path.
#'
#' @return RTF file and source dataset for baseline characteristic table.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_exposure_example()
#'
#' meta |>
#'   prepare_exp_duration(population = "apat", parameter = "expdur") |>
#'   format_exp_duration() |>
#'   rtf_exp_duration(
#'     source = "Source: [CDISCpilot: adam-adsl; adex]",
#'     path_outdata = tempfile(fileext = ".Rdata"),
#'     path_outtable = tempfile(fileext = ".rtf")
#'   )
rtf_exp_duration <- function(outdata,
                             source = "Source: [CDISCpilot: adam-adsl; adex]",
                             col_rel_width = NULL,
                             text_font_size = 9,
                             orientation = "portrait",
                             footnotes = c(
                               "Each participant is counted once on each applicable duration category row.",
                               "Duration of Exposure is the time from the first dose date to the last dose date."
                             ),
                             title = NULL,
                             path_outdata = NULL,
                             path_outtable = NULL) {
  return(
    rtf_sl_summary(
      outdata,
      source,
      col_rel_width = col_rel_width,
      text_font_size = text_font_size,
      orientation = orientation,
      footnotes = footnotes,
      title = title,
      path_outdata = path_outdata,
      path_outtable = path_outtable
    )
  )
}
