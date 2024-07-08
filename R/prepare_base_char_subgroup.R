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

#' Prepare data for treatment compliance table
#'
#' @param meta A metadata object created by metalite.
#' @param population A character value of population term name.
#'   The term name is used as key to link information.
#' @param analysis  A character value of analysis term name.
#'   The term name is used as key to link information.
#' @param parameter A character value of parameter term name.
#'   The term name is used as key to link information.
#' @param subgroup_var A character value of subgroup variable name in
#'   observation data saved in `meta$data_observation`.
#' @param subgroup_header A character vector for column header hierarchy.
#'   The first element will be the first level header and the second element
#'   will be second level header.
#' @param display_subgroup_total A logic value of displaying the total group.
#'
#' @return A list of analysis raw datasets.
#' @export
#'
#' @examples
#' #' meta <- meta_sl_example()
#' outdata <- prepare_base_char_subgroup(
#'           meta,
#'           population = "apat",
#'           parameter = "age",
#'           subgroup_var = "TRTA",
#'           subgroup_header = c("SEX","TRTA"),
#'           display_subgroup_total = TRUE)


prepare_base_char_subgroup <- function(
    meta,
    population,
    analysis = "base_char_subgroup",
    parameter,
    subgroup_var,
    subgroup_header = c(meta$population[[population]]$group, subgroup_var),
    display_subgroup_total = TRUE) {
  
  meta_original <- meta
  
  observation <- meta$plan[meta$plan$analysis==analysis,]$observation
  
  #Factor Level 1 Subgroup
  meta$data_population[[subgroup_header[1]]] <- factor(
    as.character(meta$data_population[[subgroup_header[1]]]),
    levels = sort(unique(meta$data_population[[subgroup_header[1]]]))
  )
  meta$data_observation[[subgroup_header[1]]] <- factor(
    as.character(meta$data_observation[[subgroup_header[1]]]),
    levels = sort(unique(meta$data_observation[[subgroup_header[1]]]))
  )
  
  #Factor Level 2 Subgroup
  meta$data_population[[subgroup_var]] <- factor(
    as.character(meta$data_population[[subgroup_var]]),
    levels = sort(unique(meta$data_population[[subgroup_var]]))
  )
  meta$data_observation[[subgroup_var]] <- factor(
    as.character(meta$data_observation[[subgroup_var]]),
    levels = sort(unique(meta$data_observation[[subgroup_var]]))
  )
  
  meta$observation[[observation]]$group <- subgroup_header[1]
  meta$population[[population]]$group <- subgroup_header[1]
  
  # Obtain variables
  par_var <- collect_adam_mapping(meta, parameter)$var
  
  meta_subgroup <- metalite::meta_split(meta, subgroup_header[2])
  
  outdata_all <- prepare_sl_summary(
    meta,
    analysis = analysis,
    population = meta$plan[meta$plan$analysis==analysis,]$population,
    parameter = parameter
  )
  
  outdata_subgroup <- lapply(
    meta_subgroup,
    prepare_sl_summary,
    analysis = analysis,
    population = meta$plan[meta$plan$analysis==analysis,]$population,
    parameter = parameter
  )
  
  out_all <- outdata_subgroup
  out_all$Total <- outdata_all
  
  group <- as.character(outdata_subgroup[[1]]$group_label)
  group <- group[!group %in% "Total"]
  
  outdata <- list(
    group = group,
    subgroup = tools::toTitleCase(tolower(names(outdata_subgroup))),
    display_subgroup_total = display_subgroup_total,
    meta = meta_original,
    population = population,
    observation = observation,
    parameter = parameter,
    out_all = out_all
  )
  
}
  