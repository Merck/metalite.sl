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

#' Prepare data for Subgroup Analysis for Baseline Characteristic
#'
#' @param outdata A metadata object created by [prepare_base_char_subgroup()].
#' @param display Column wants to display on the table.
#'   The term could be selected from `c("n", "prop", "total")`.
#'   "total" can display the total column for the first level header.
#' @param display_stat A vector of statistics term name.
#'   The term name could be selected from
#'   `c("mean", "sd", "se", "median", "q1 to q3", "range", "q1", "q3", "min", "max")`.
#' @param display_total A logic value of displaying the total column
#'   for the second level header.
#'
#' @return A list of analysis raw datasets.
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#'
#' outdata <- prepare_base_char_subgroup(
#'   meta,
#'   population = "apat",
#'   parameter = "age",
#'   subgroup_var = "TRTA",
#'   subgroup_header = c("SEX", "TRTA")
#' )
#'
#' outdata |> format_base_char_subgroup()
format_base_char_subgroup <- function(
    outdata,
    display = c("n", "prop", "total"),
    display_stat = c("mean", "sd", "median", "range"),
    display_total = TRUE) {
  out_all <- outdata$out_all

  outlst <- list()
  for (i in seq_along(out_all)) {
    tbl <- out_all[[i]] |>
      format_base_char(
        display_col = display,
        digits_prop = 1,
        display_stat = display_stat
      )

    names(tbl$tbl)[-1] <- ifelse(grepl("_label", names(tbl$tbl)[-1]) %in% "FALSE", paste0(names(out_all[i]), names(tbl$tbl)[-1]), names(tbl$tbl)[-1])

    # Get row order from total
    if (i == length(out_all)) {
      tbl_order <- tbl$tbl[, c("name", "var_label")]
      tbl_order$order <- as.numeric(rownames(tbl$tbl))
    }

    outlst[[i]] <- tbl$tbl
  }

  names(outlst) <- names(out_all)
  if (!display_total) {
    outlst <- outlst[-length(outlst)]
  }

  # Left join to the frame with order
  tbl <- tbl_order
  for (x in outlst) {
    tbl <- merge(tbl, x, by = c("name", "var_label"), all.x = TRUE)
  }

  # Assign zero for missing data
  max_nchar <- apply(tbl[!tbl$name %in% c("Mean", "SD", "Median", "Range"), ], 2, function(x) {
    max(nchar(x), na.rm = TRUE)
  })
  tbl <- apply(tbl, 1, function(x) {
    if (is.na(x[["name"]]) | x[["name"]] %in% c("Participants in population", "Mean", "SD", "Median", "Range")) {
      x
    } else {
      sapply(names(tbl), function(y) {
        if (grepl("n_", y) & is.na(x[[y]])) {
          x[[y]] <- "0"
        } else if (grepl("p_", y) & is.na(x[[y]])) {
          x[[y]] <- paste0(paste0(rep(" ", (max_nchar[[y]] - 5)), collapse = ""), "(0.0)")
        } else {
          x[[y]]
        }
      })
    }
  }, simplify = TRUE) |>
    t() |>
    as.data.frame()

  outdata$tbl <- tbl[order(tbl$order), ]
  outdata$display <- display
  outdata$display_stat <- display_stat
  outdata$display_total <- display_total
  outdata
}
