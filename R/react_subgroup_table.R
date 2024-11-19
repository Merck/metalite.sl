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

#' Create interactive table for a subgroup
#'
#' @param tbl A tibble to create reactable.
#' @param group Treatment group label.
#' @param subgroup_name Subgroup label.
#'
#' @return A reactable combining both baseline characteristic table
#'   and AE subgroup specific tables for a subgroup.
react_subgroup_table <- function(
    tbl,
    group,
    subgroup_name) {
  names(tbl) <- tolower(names(tbl))
  subgroup_name <- tolower(subgroup_name)
  race_columns <- grep(tolower(subgroup_name), tolower(names(tbl)), value = TRUE)

  selected_columns <- c("name", race_columns)

  formatted_data <- tbl[, selected_columns]

  prop_prefix <- paste0(subgroup_name, "prop_")
  n_prefix <- paste0(subgroup_name, "n_")

  prop_indices <- grep(prop_prefix, names(formatted_data))
  n_indices <- grep(n_prefix, names(formatted_data))

  # formatted_data <- formatted_data[, c(1, prop_indices, n_indices)]

  num_columns <- length(prop_indices)

  col_defs <- list()
  col_group_defs <- list()
  all_columns <- c("name")

  js_filterminvalue <- readLines(system.file("js/filterMinValue.js", package = "metalite.sl"))
  js_rangeFilter <- readLines(system.file("js/rangeFilter.js", package = "metalite.sl"))

  for (i in seq_len(num_columns)) {
    prop_name <- names(formatted_data)[prop_indices[i]]
    prop_num_name <- sub(prop_prefix, paste0(prop_name, "_num"), prop_name)

    n_name <- names(formatted_data)[n_indices[i]]

    formatted_data[[prop_num_name]] <- ifelse(is.na(formatted_data[[prop_name]]), 0, defmt_pct(formatted_data[[prop_name]]))

    all_columns <- append(all_columns, c(n_name, prop_name, prop_num_name))

    col_defs[["name"]] <- reactable::colDef(show = TRUE, searchable = TRUE, minWidth = 500)
    col_defs[[n_name]] <- reactable::colDef(name = "n", show = TRUE, na = "", searchable = FALSE)
    col_defs[[prop_name]] <- reactable::colDef(show = FALSE)
    col_defs[[prop_num_name]] <- reactable::colDef(name = "%", filterMethod = reactable::JS(js_filterminvalue), filterInput = reactable::JS(js_rangeFilter))

    col_group_defs <- append(col_group_defs, list(reactable::colGroup(name = group[i], columns = c(n_name, prop_name, prop_num_name))))
  }

  formatted_data <- formatted_data |> dplyr::select(dplyr::all_of(all_columns))

  reactable::reactable(
    formatted_data,
    filterable = TRUE,
    columns = col_defs,
    columnGroups = col_group_defs
  )
}
