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

#' Deformat percent
#'
#' @param pct string eager to remove percent
#'
#' @return Numeric value without percent
#' @export
#'
#' @examples
#' defmt_pct("10.0%")
#' defmt_pct(c("10.0%", "(11.2%)"))
defmt_pct <- function(pct) {
  as.numeric(stringr::str_extract(pct, "\\d+\\.*\\d*"))
}

#' Save outputs for RTF generation
#'
#' @param outdata An `outdata` object.
#' @param path_outdata A character string of file path to save the outdata.
#' @param pat_outtable A character string of file path to save the RTF table.
#'
#' @noRd
rtf_output <- function(
  outdata,
  path_outdata,
  path_outtable
) {
  if (!is.null(path_outdata)) {
    save(outdata, file = path_outdata)
    message("The outdata is saved in", normalizePath(path_outdata))
  }

  if (!is.null(path_outtable)) {
    outdata$rtf |>
      r2rtf::rtf_encode() |>
      r2rtf::write_rtf(file = path_outtable)
    message("The output is saved in", normalizePath(path_outtable))
  }

  invisible(outdata)
}

#' Obtain a list of category ranges from a character label for exposure duration analysis
#'
#' @param labels A character vector of a category label
#'
#' @noRd
extract_duration_category_ranges <- function(labels) {
  times <- labels |>
    stringr::str_extract_all(pattern = "\\d+") |>
    lapply(function(x) {
      if (length(x) == 0) {
        stop("A real number for duration category is not recognized. Please rename the category label in the input data, or use `duration_category_list` and `duration_category_labels`.")
      }
      as.numeric(x)
    })

  factors <- labels |>
    stringr::str_extract_all(pattern = "\\d+ ?([a-zA-Z]+)") |>
    lapply(
      function(x) {
        unit <- stringr::str_extract(x, pattern = "\\d+ ?([a-zA-Z])", group = 1)
        factor <- sapply(unit, USE.NAMES = FALSE, function(y) {
          if (toupper(y) == "D") {
            1
          } else if (toupper(y) == "W") {
            7
          } else if (toupper(y) == "M") {
            30.4367
          } else if (toupper(y) == "Y") {
            365.24
          } else {
            warning("The unit of duration category is not recognized. The unit is handled as day(s).")
            1
          }
        })
        return(factor)
      }
    )

  list <- lapply(
    seq_along(times),
    function(x) {
      if (length(times[[x]]) < 2) {
        time <- c(times[[x]], rep(NA, 2 - length(times[[x]])))
      } else {
        time <- times[[x]]
      }
      if (length(factors[[x]]) == 1) {
        factor <- rep(factors[[x]], 2)
      } else if (length(factors[[x]]) == 0) {
        factor <- rep(1, 2)
      } else {
        factor <- factors[[x]]
      }
      return(time * factor)
    }
  )
  return(list)
}
