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
#' @param metadata_ae A metadata created by metalite,
#'   which builds the AE subgroup specific table
#' @param population A character value of population term name.
#'   The term name is used as key to link information.
#' @param observation A character value of observation term name.
#'   The term name is used as key to link information.
#' @param display_total Display total column or not.
#' @param sl_parameter A character value of parameter term name for
#'   the baseline characteristic table.
#'   The term name is used as key to link information.
#' @param ae_subgroup A vector of strubf to specify the subgroups
#'   in the AE subgroup specific table.
#' @param ae_specific A string specifying the AE specific category.
#' @param width A numeric value of width of the table in pixels.
#'
#' @return An reactable combing both baseline characteristic table
#'   and AE subgroup specific tables.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#'   react_base_char(
#'     metadata_sl = meta_sl_example(),
#'     metadata_ae = metalite.ae::meta_ae_example(),
#'     population = "apat",
#'     observation = "wk12",
#'     display_total = TRUE,
#'     sl_parameter = "age;gender;race",
#'     ae_subgroup = c("age", "race", "gender"),
#'     ae_specific = "rel",
#'     width = 1200
#'   )
#' }
react_base_char <- function(
    metadata_sl,
    metadata_ae,
    population = "apat",
    observation = "wk12",
    display_total = TRUE,
    sl_parameter = "age;gender;race",
    ae_subgroup = c("gender", "race"),
    ae_specific = "rel",
    width = 1200) {
  # ----------------------------------------- #
  #   total setting                           #
  # ----------------------------------------- #

  if (display_total == TRUE) {
    display_sl <- c("n", "prop", "total")
  } else {
    display_sl <- c("n", "prop")
  }

  # ---------------------------------------------- #
  #   ensure capitalizing the first letter of RACE #
  # ---------------------------------------------- #
  
  # function to capitalize the first letter of each word
  capitalize_words <- function(x) {
    sapply(x, function(word) {
      paste0(toupper(substr(word, 1, 1)), tolower(substr(word, 2, nchar(word))))
    })
  }

  # 1) In data_population: extract the RACE values as a character vector
  race_values_pop <- metadata_sl[["data_population"]]$RACE  # Use $ to get a vector
  
  # Capitalize the race values
  metadata_sl[["data_population"]]$RACE <- capitalize_words(race_values_pop)  # Assign back as a vector
  
  # 2) In data_observation: extract the RACE values as a character vector
  race_values_obs <- metadata_sl[["data_observation"]]$RACE  # Use $ to get a vector
  
  # Capitalize the race values
  metadata_sl[["data_observation"]]$RACE <- capitalize_words(race_values_obs)  # Assign back as a vector
  
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
  #   prepare the AE subgroup table numbers   #
  # ----------------------------------------- #
  # get the variable name of the subgroup
  ae_subgrp_var <- NULL
  ae_subgrp_label <- NULL
  for (x_subgrp in ae_subgroup) {
    if (length(metalite::collect_adam_mapping(metadata_sl, x_subgrp)$vargroup) > 0) {
      ae_subgrp_var <- c(ae_subgrp_var, metalite::collect_adam_mapping(metadata_sl, x_subgrp)$vargroup)
    } else {
      ae_subgrp_var <- c(ae_subgrp_var, metalite::collect_adam_mapping(metadata_sl, x_subgrp)$var)
    }
    ae_subgrp_label <- c(ae_subgrp_label, metalite::collect_adam_mapping(metadata_sl, x_subgrp)$label)
  }

  # get the AE subgroup tables
  tbl_ae <- list()
  group_ae <- list()

  # define the space character
  space_char <- "\u2003\u2003"

  for (y_subgrp in ae_subgrp_var) {
    sl_pop_subgrp <- metalite::collect_population_record(metadata_sl, population, var = y_subgrp)[[y_subgrp]]
    ae_pop_subgrp <- metalite::collect_population_record(metadata_ae, population, var = y_subgrp)[[y_subgrp]]
    if (is.factor(sl_pop_subgrp)) {
      sl_pop_subgrp <- tolower(unique(levels(sl_pop_subgrp)))
    } else {
      sl_pop_subgrp <- tolower(unique(sl_pop_subgrp))
    }
    ae_pop_subgrp <- tolower(unique(as.character(ae_pop_subgrp)))
    if (!identical(all.equal(sl_pop_subgrp, ae_pop_subgrp), TRUE)) {
      stop(paste0(
        "For ", y_subgrp, " variable in lowcase, ",
        "the values or factor levels in `data_population` for sl should be identical to the values in `data_population` for ae. ",
        "sl: ", paste0(sl_pop_subgrp, collapse = ", "), "; ",
        "ae: ", paste0(ae_pop_subgrp, collapse = ", ")
      ))
    }

    tbl_ae_temp <- metalite.ae::prepare_ae_specific_subgroup(
      metadata_ae,
      population = population,
      observation = observation,
      parameter = ae_specific,
      subgroup_var = y_subgrp,
      display_subgroup_total = FALSE # total display for subgroup is not needed
    ) |>
      metalite.ae::format_ae_specific_subgroup()

    # modify the name elements in tbl_ae_temp$tbl: add spaces in name other than the value of "Participants in population"
    tbl_ae_temp$tbl$name <- sapply(tbl_ae_temp$tbl$name, function(x) {
      if (trimws(x) == "Participants in population") {
        return(x) # return the original value without modification
      } else {
        # Pad with spaces to a fixed width (e.g., 10 characters)
        return(paste0(space_char, x)) # Prepend spaces
      }
    })

    tbl_ae <- c(tbl_ae, list(tbl_ae_temp$tbl))
    # get group labels for AE analysis
    group_ae <- c(group_ae, list(tbl_ae_temp$group))
    # Note: Need to confirm whether treatment total can be displayed in ae subgroup
    # if (display_total == TRUE){
    #   group_ae <- c(group_ae, list(tbl_ae_temp$group))
    # } else {
    #   group_ae <- c(group_ae, list(tbl_ae_temp$group[!(tbl_ae_temp$group %in% "total")]))
    # }
  }

  # get the AE specific
  ae_specific_outdata <- metalite.ae::prepare_ae_specific(
    metadata_ae,
    population = population,
    observation = observation,
    parameter = ae_specific
  ) |>
    metalite.ae::format_ae_specific(display = display_sl)

  # modify the name elements in ae_specific_outdata$tbl$name: add spaces in name other than the value of "Participants in population"
  ae_specific_outdata$tbl$name <- sapply(ae_specific_outdata$tbl$name, function(x) {
    if (trimws(x) == "Participants in population" || is.na(x)) {
      return(x) # return the original value without modification
    } else {
      return(paste0(space_char, x)) # Prepend spaces
    }
  })

  # Define Column and Column Group for AE specific
  col_defs_ae <- list()
  col_group_defs_ae <- list()
  col_defs_ae[["name"]] <- reactable::colDef(name = " ")
  for (i in 1:length(ae_specific_outdata$group)) {
    col_defs_ae[[paste0("n_", i)]] <- reactable::colDef(name = "n")
    col_defs_ae[[paste0("prop_", i)]] <- reactable::colDef(name = "(%)")

    col_group_defs_ae <- append(
      col_group_defs_ae,
      list(reactable::colGroup(
        name = ae_specific_outdata$group[i],
        columns = c(paste0("n_", i), paste0("prop_", i))
      ))
    )
  }


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

  reactable::reactable(
    tbl_sl,
    groupBy = "var_label",
    width = width,
    columns = col_defs,
    columnGroups = col_group_defs,
    details = function(index) {
      if (index > 1 &
        !(tolower(tbl_sl$name[index]) %in% c("mean", "sd", "median", "min", "max", "se", "q1", "q3", "q1 to q3", "range")) &
        tbl_sl$var_label[index] %in% ae_subgrp_label & !is.na(tbl_sl$name[index])
      ) {
        # get the index of the AE subgroup variable by the index in the baseline char table
        idx_ae_subgroup <- which(tbl_sl$var_label[index] == ae_subgrp_label)

        # get the table for this AE subgroup variable
        tbl_ae[[idx_ae_subgroup]] |>
          react_subgroup_table(
            group = group_ae[[idx_ae_subgroup]],
            subgroup_name = tbl_sl$name[index]
          )
      } else if (index == 1) {
        ae_specific_outdata$tbl |>
          reactable::reactable(
            width = width,
            columns = col_defs_ae,
            columnGroups = col_group_defs_ae,
          )
      }
    }
  )
}
