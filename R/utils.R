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
