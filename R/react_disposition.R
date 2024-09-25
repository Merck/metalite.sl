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

#' Display interactive disposition tables with AE subgroup analysis
#'
#' @param metadata_sl A metadata created by [metalite],
#'   which builds the baseline characteristic table
#' @param metadata_ae A metadata created by [metalite],
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
#'   react_disposition(
#'     metadata_sl = meta_sl_example(),
#'     metadata_ae = metalite.ae::meta_ae_example(),
#'     width = 1200
#'   )
#' }
react_disposition <- function(
    metadata_sl,
    metadata_ae,
    analysis = 'disp',
    population = metadata_sl$plan[metadata_sl$plan$analysis==analysis,]$population,
    sl_parameter = paste(metadata_sl$plan[metadata_sl$plan$analysis==analysis,]$parameter, collapse = ";"),
    # observation = "wk12",
    display_total = TRUE,
    #ae_subgroup = c("gender", "race"),
    #ae_specific = "rel",
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
    prepare_disposition(
      population = population,
      analysis = analysis,
      parameter = sl_parameter
    ) |>
    format_disposition(display_col = display_sl, digits_prop = 2)
  
  tbl_sl <- x_sl$tbl
  tbl_sl$var_label[tbl_sl$name == "Participants in population"] <- "Participants in population"
  
  # ----------------------------------------- #
  #   prepare the AE subgroup table numbers   #
  # ----------------------------------------- #
  # get the variable name of the subgroup
  # ae_subgrp_var <- NULL
  # ae_subgrp_label <- NULL
  # for (x_subgrp in ae_subgroup) {
  #   if (length(metalite::collect_adam_mapping(metadata_sl, x_subgrp)$vargroup) > 0) {
  #     ae_subgrp_var <- c(ae_subgrp_var, metalite::collect_adam_mapping(metadata_sl, x_subgrp)$vargroup)
  #   } else {
  #     ae_subgrp_var <- c(ae_subgrp_var, metalite::collect_adam_mapping(metadata_sl, x_subgrp)$var)
  #   }
  #   ae_subgrp_label <- c(ae_subgrp_label, metalite::collect_adam_mapping(metadata_sl, x_subgrp)$label)
  # }
  
  # get the AE subgroup tables
  # tbl_ae <- list()
  # group_ae <- list()
  # 
  # for (y_subgrp in ae_subgrp_var) {
  #   tbl_ae_temp <- metalite.ae::prepare_ae_specific_subgroup(
  #     metadata_ae,
  #     population = population,
  #     observation = observation,
  #     parameter = ae_specific,
  #     subgroup_var = y_subgrp,
  #     display_subgroup_total = FALSE # total display for subgroup is not needed
  #   ) |>
  #     format_ae_specific_subgroup()
  #   
  #   tbl_ae <- c(tbl_ae, list(tbl_ae_temp$tbl))
  #   # get group labels for AE analysis
  #   group_ae <- c(group_ae, list(tbl_ae_temp$group))
  #   # Note: Need to confirm whether treatment total can be displayed in ae subgroup
  #   # if (display_total == TRUE){
  #   #   group_ae <- c(group_ae, list(tbl_ae_temp$group))
  #   # } else {
  #   #   group_ae <- c(group_ae, list(tbl_ae_temp$group[!(tbl_ae_temp$group %in% "total")]))
  #   # }
  # }
  
  # get the AE specific
  # ae_listing_outdata <- metalite.ae::prepare_ae_listing(
  #   metadata_ae,
  #   analysis = 'ae_listing',
  #   population = population,
  #   observation = observation,
  #   parameter = 'any'
  # ) |>
  #   forestly:::format_ae_listing(display = display_sl)
  
  ae_listing_outdata <- metalite.ae::prepare_ae_specific(metadata_ae, "apat", "wk12", "any") |>
    forestly:::collect_ae_listing(
      c(
        "USUBJID", "SEX", "RACE", "AGE", "ASTDY", "AESEV", "AESER",
        "AEREL", "AEACN", "AEOUT", "SITEID", "ADURN", "ADURU", "AOCCPFL"
      )
    ) |>
    forestly:::format_ae_listing()
  
  # Define Column and Column Group for AE specific
  # col_defs_ae <- list()
  # col_group_defs_ae <- list()
  # col_defs_ae[["name"]] <- reactable::colDef(name = " ")
  # for (i in 1:length(ae_specific_outdata$group)) {
  #   col_defs_ae[[paste0("n_", i)]] <- reactable::colDef(name = "n")
  #   col_defs_ae[[paste0("prop_", i)]] <- reactable::colDef(name = "(%)")
  #   
  #   col_group_defs_ae <- append(
  #     col_group_defs_ae,
  #     list(reactable::colGroup(
  #       name = ae_specific_outdata$group[i],
  #       columns = c(paste0("n_", i), paste0("prop_", i))
  #     ))
  #   )
  # }
  
  # ----------------------------------------- #
  #   build interactive disposition table     #
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
  
  details = function(index) {
    dcsreas <- stringr::str_trim(tolower(tbl_sl$name[index]))
    if ( dcsreas %in% c("adverse event") & !is.na(tbl_sl$name[index]) ) {
      if (stringr::str_trim(tolower(tbl_sl$var_label[index]))=="trial disposition") {
        var <- metadata_sl$parameter[['disposition']]$var
      }
      if (stringr::str_trim(tolower(tbl_sl$var_label[index]))=="participant ptudy medication disposition"){
        var <- metadata_sl$parameter[['medical-disposition']]$var
      }
      # get dicontinued subject list
      usubjids <- x_sl$meta$data_population |> dplyr::filter(tolower(DCSREAS)==dcsreas & tolower(!!as.symbol(var))=="discontinued") |> dplyr::pull(USUBJID)
      subj_list <- metadata_sl$data_population |> dplyr::filter(USUBJID %in% usubjids)
      subj_list |>
      reactable::reactable(
        details = subj_details
      )
    } 
  }
  
  subj_details <- function(index) {
    usubjid <- subj_list$USUBJID[index]
    sub_ae_listing <- ae_listing_outdata$ae_listing |> dplyr::filter(Unique_Participant_ID %in% usubjid)
    sub_ae_listing |>
      reactable::reactable(
      )
  }
  subj_list <- data.frame()
  reactable::reactable(
    tbl_sl,
    groupBy = "var_label",
    width = width,
    columns = col_defs,
    columnGroups = col_group_defs,
    details = details
  )
}
