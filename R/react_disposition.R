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
#' @param metadata_sl A metadata created by metalite,
#'   which builds the baseline characteristic table
#' @param metadata_ae A metadata created by metalite,
#'   which builds the AE subgroup specific table
#' @param analysis The analysis label provided in \code{metadata_sl}.
#' @param trtvar A character that indicate variable for the treatment group.
#' @param population A character value of population term name.
#'   The term name is used as key to link information.
#' @param display_total Display total column or not.
#' @param sl_parameter A character value of parameter term name for
#'   the baseline characteristic table.
#'   The term name is used as key to link information.
#' @param sl_col_selected A character vector of variable which will be shown in the participant detail.
#' @param sl_col_names A character vector for the columns names of the participant detail. Same length as sl_col_selected.
#' @param ae_observation The meta parameter of the observation in adverse event listing.
#' @param ae_population The meta parameter of the population in adverse event listing.
#' @param ae_col_selected A character vector of variable which will be shown in the AE detail.
#' @param ae_col_names A character vector for the columns names of the AE detail. Same length as ae_col_selected.
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
#'     metadata_ae = metalite.ae::meta_ae_example()
#'   )
#' }
react_disposition <- function(
    metadata_sl,
    metadata_ae,
    analysis = "disp",
    trtvar = "trt01a",
    population = metadata_sl$plan$population[metadata_sl$plan$analysis == analysis],
    sl_parameter = paste(metadata_sl$plan$parameter[metadata_sl$plan$analysis == analysis], collapse = ";"),
    sl_col_selected = NULL,
    sl_col_names = NULL,
    ae_observation = "wk24",
    ae_population = population,
    ae_col_selected = NULL,
    ae_col_names = NULL,
    display_total = TRUE,
    width = 1200) {
  # ----------------------------------------- #
  #   default columns                         #
  # ----------------------------------------- #
  if (is.null(sl_col_selected)) {
    sl_col_selected <- c("trt01a", "siteid", "subjid", "sex", "age", "weightbl")
    sl_col_names <- c("Treatment", "Site", "Subject ID", "Sex", "Age (Year)", "Weight (kg)")
  }

  if (is.null(ae_col_selected)) {
    ae_col_selected <- c("AESOC", "ASTDT", "AENDT", "AETERM", "duration", "AESEV", "AESER", "related", "AEACN", "AEOUT")
    ae_col_names <- c("SOC", "Onset Date", "End Date", "AE", "Duraion", "Intensity", "Serious", "Related", "Action Taken", "Outcome")
  }

  # ----------------------------------------- #
  #   total setting                           #
  # ----------------------------------------- #

  if (display_total == TRUE) {
    display_sl <- c("n", "prop", "total")
  } else {
    display_sl <- c("n", "prop")
  }

  # ----------------------------------------- #
  #   prepare the disposition table numbers   #
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
  sl_col_selected <- toupper(sl_col_selected)
  if (!("USUBJID" %in% sl_col_selected)) u_sl_col_selected <- c("USUBJID", sl_col_selected)
  if (is.null(sl_col_names)) sl_col_names <- sl_col_selected
  sl_col_def <- list()
  for (i in 1:length(sl_col_selected)) sl_col_def[[sl_col_selected[i]]] <- reactable::colDef(sl_col_names[i])

  # ----------------------------------------- #
  #   get AE listing                          #
  # ----------------------------------------- #
  ae_listing_outdata <-
    metalite.ae::prepare_ae_listing(meta = metadata_ae, population = ae_population, analysis = "ae_specific", observation = ae_observation, parameter = "any")
  ae_list <- ae_listing_outdata$meta$data_observation

  # Define columns for AE list
  if (is.null(ae_col_names)) ae_col_names <- ae_col_selected
  ae_col_def <- list()
  for (i in 1:length(ae_col_selected)) ae_col_def[[ae_col_selected[i]]] <- reactable::colDef(ae_col_names[i])


  # ----------------------------------------- #
  #   making react table                      #
  # ----------------------------------------- #
  trt_grp <- toupper(trtvar)
  # show participant details when category not in "participants in population", "discontinued", "participants ongoing", "complete"
  details <- function(index) {
    dcsreas <- stringr::str_trim(tolower(tbl_sl$name[index]))
    if (!is.na(tbl_sl$name[index]) & !(dcsreas %in% c("participants in population", "discontinued", "participants ongoing", "complete"))) {
      if (stringr::str_trim(tolower(tbl_sl$var_label[index])) == "trial disposition") {
        var <- metadata_sl$parameter[["disposition"]]$var
        var_lower <- metadata_sl$parameter[["disposition"]]$var_lower
      }
      if (stringr::str_trim(tolower(tbl_sl$var_label[index])) == "participant study medication disposition") {
        var <- metadata_sl$parameter[["medical-disposition"]]$var
        var_lower <- metadata_sl$parameter[["medical-disposition"]]$var_lower
      }
      # get discontinued subject list
      usubjids <- x_sl$meta$data_population$USUBJID |> subset(tolower(x_sl$meta$data_population[[var_lower]]) == dcsreas & tolower(x_sl$meta$data_population[[var]]) == "discontinued")
      subj_list <- metadata_sl$data_population |> subset(
        subset = metadata_sl$data_population$USUBJID %in% usubjids,
        select = u_sl_col_selected
      )
      subj_list[, sl_col_selected] |>
        reactable::reactable(
          filterable = TRUE, defaultExpanded = FALSE, striped = TRUE, groupBy = trt_grp,
          columns = sl_col_def,
          details = function(index) {
            usubjid <- subj_list$USUBJID[index]
            # get AE list of a subject if discontinued because of AE
            if ((var == "EOTSTT" && dcsreas %in% c("adverse event")) | (var == "EOSSTT" && dcsreas %in% c("other"))) {
              sub_ae_listing <- ae_list |> subset(
                subset = ae_list$USUBJID %in% usubjid,
                select = ae_col_selected
              )
              sub_ae_listing |> reactable::reactable(striped = FALSE, columns = ae_col_def, defaultExpanded = FALSE)
            }
          }
        )
    }
  }


  reactable::reactable(
    tbl_sl,
    sortable = FALSE,
    groupBy = "var_label",
    width = width,
    columns = col_defs,
    columnGroups = col_group_defs,
    details = details
  )
}
