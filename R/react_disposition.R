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
    display_total = TRUE,
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
 
  # get AE listing
  
  ae_listing_outdata <- metalite.ae::prepare_ae_specific(metadata_ae, "apat", "wk12", "any") |>
    forestly:::collect_ae_listing(
      c(
        "USUBJID", "SEX", "RACE", "AGE", "ASTDT", "ASTDY", "AESEV", "AESER",
        "AEREL", "AEACN", "AEOUT", "SITEID", "ADURN", "ADURU", "AOCCPFL"
      )
    ) |>
    forestly:::format_ae_listing()
  
  
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
  
  # Define columns for subject list
  sl_selected <- toupper(c( 'trt01a', 'usubjid', 'siteid', 'subjid', 'sex', 'age', 'weightbl'))
  sl_sel_names <- c('Treatment', 'Unique Subjet ID', 'Site', 'Subject ID', 'Sex', 'Age (Year)', 'Weight (kg)')
  sl_col_def <- list()
  for (i in 1:length(sl_selected)) sl_col_def[[sl_selected[i]]] <- reactable::colDef(sl_sel_names[i])
  
  # Define columns for AE list
  ae_selected <- c('SOC_Name', 'ASTDT', 'Relative_Day_of_Onset', 'Adverse_Event', 'Duration', 'Intensity', 'Serious', 'Related', 'Action_Taken', 'Outcome')
  ae_sel_names <- c('SOC', 'Onset Date', 'Relative Day of Onset', 'AE', 'Duraion', 'Intensity', 'Serious', 'Related', 'Action Taken', 'Outcome')
  ae_col_def <- list()
  for (i in 1:length(ae_selected)) ae_col_def[[ae_selected[i]]] <- reactable::colDef(ae_sel_names[i])
  
  trt_grp <-  toupper('trt01a')
  details <- function(index) {
    dcsreas <- stringr::str_trim(tolower(tbl_sl$name[index]))
    if (!is.na(tbl_sl$name[index]) & !(dcsreas %in% c("participants in population", "discontinued", "participants ongoing", "completed"))) {
      if (stringr::str_trim(tolower(tbl_sl$var_label[index]))=="trial disposition") {
        var <- metadata_sl$parameter[['disposition']]$var
      }
      if (stringr::str_trim(tolower(tbl_sl$var_label[index]))=="participant ptudy medication disposition"){
        var <- metadata_sl$parameter[['medical-disposition']]$var
      }
      # get discontinued subject list
      usubjids <- x_sl$meta$data_population$USUBJID |> subset(tolower(x_sl$meta$data_population$DCSREAS)==dcsreas &  tolower(x_sl$meta$data_population[[var]])=="discontinued")
      subj_list <- metadata_sl$data_population |> subset(subset = metadata_sl$data_population$USUBJID %in% usubjids,
                                                         select = sl_selected )
      subj_list |>
      reactable::reactable(filterable = T, defaultExpanded = F, striped = T, groupBy =trt_grp,
        columns = sl_col_def,
        details = function(index) {
          usubjid <- subj_list$USUBJID[index]
          # get AE list of a subject
          if ( dcsreas %in% c("adverse event")){
            sub_ae_listing <- ae_listing_outdata$ae_listing |> subset(subset = ae_listing_outdata$ae_listing$Unique_Participant_ID %in% usubjid, 
                                                                      select = ae_selected)
            sub_ae_listing |> reactable::reactable(striped = F, columns = ae_col_def, defaultExpanded = F) 
          }
          
        }
      )
    } 
  }


  reactable::reactable(
    tbl_sl,
    groupBy = "var_label",
    width = width,
    columns = col_defs,
    columnGroups = col_group_defs,
    details = details
  )
}
