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

#' Display interactive baseline characteristic tables with AE subgroup analysis
#'
#' @param metadata_sl A metadata created by metalite,
#'   which builds the baseline characteristic table
#' @param population A character value of population term name.
#'   The term name is used as key to link information.
#' @param display_total Display total column or not.
#' @param sl_parameter A character value of parameter term name for
#'   the baseline characteristic table.
#'   The term name is used as key to link information.
#' @param width A numeric value of width of the table in pixels.
#'
#' @return An reactable combing both baseline characteristic table
#'   and AE subgroup specific tables.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#' react_base_char_new(metadata_sl = meta_sl_example(),
#'                    population = "apat",
#'                    observation = "wk12",
#'                    display_total = TRUE,
#'                    sl_parameter = "age;gender;race",
#'                    width = 1200)
#' }
react_base_char_new <- function(
    metadata_sl,
    population = "apat",
    observation = "wk12",
    display_total = TRUE,
    sl_parameter = "age;gender;race",
    width = 1200) {
  # ----------------------------------------- #
  #   total setting                           #
  # ----------------------------------------- #

  if (display_total == TRUE) {
    display_sl <- c("n", "prop", "total")
  } else {
    display_sl <- c("n", "prop")
  }

  # ----------------------------------------- #
  #   prepare the baseline char table numbers #
  # ----------------------------------------- #
  x_sl <- metadata_sl |>
    prepare_sl_summary(
      population = population,
      analysis = metadata_sl$plan$analysis,
      parameter = sl_parameter
    ) |>
    format_base_char(display_col = display_sl, digits_prop = 2)

  tbl_sl <- x_sl$tbl
  tbl_sl$var_label[tbl_sl$name == "Participants in population"] <- "Participants in population"

  # ----------------------------------------- #
  #   build interactive baseline char table   #
  # ----------------------------------------- #
  # Define Column
  col_defs <- list()
  for (sl_name in names(tbl_sl)) {
    if (startsWith(sl_name, "n_")) {
      col_defs[[sl_name]] <- reactable::colDef(name = "n")
    } else if (startsWith(sl_name, "p_")) {
      col_defs[[sl_name]] <- reactable::colDef(name = "(%)")
    } else {
      col_defs[[sl_name]] <- reactable::colDef(name = " ")
    }
  }

  # Define Column Group
  col_group_defs <- list()
  for (i in 1:length(x_sl$group_label)) {
    group <- levels(x_sl$group_label)[i]
    col_group_defs <- append(
      col_group_defs,
      list(reactable::colGroup(
        name = group,
        columns = c(paste0("n_", i), paste0("p_", i))
      ))
    )
  }
  if (display_total == TRUE) {
    col_group_defs <- append(
      col_group_defs,
      list(reactable::colGroup(
        name = "Total",
        columns = c("n_9999", "p_9999")
      ))
    )
  }
  
  tbl_sl_shared <- crosstalk::SharedData$new(tbl_sl) 
  shiny::fluidRow(
    shiny::column(
      4,
      crosstalk::filter_checkbox("var_label", "Select your baseline characteristics to view", tbl_sl_shared, ~var_label)
    ),
    shiny::column(
      8,
      reactable::reactable(tbl_sl_shared, groupBy = "var_label",
                           width = width, columns = col_defs,
                           columnGroups = col_group_defs)
    )
  )
  
}
