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

#' Create metadata for subject-level analysis table
#'
#' @param dataset_population Source dataset of population.
#' @param dataset_observation Source dataset of observation
#' @param population_term A character value of population term name.
#' @param observation_term A character value of observation term name.
#' @param parameter_term A character value of parameter term name.
#'   If there are multiple terms, they are separated by the semicolon (;).
#' @param parameter_var A character value of parameter variable name.
#'   If there are multiple variables, they are separated by the semicolon (;).
#'   A group variable can be specified followed by a variable
#'   and the hat symbol (^).
#' @param parameter_labels A character vector of parameter label name.
#'   The length of vector should be the same as the number of parameter terms.
#'   A label from an input data is used if `NA` for a variable is specified.
#' @param analysis_term A character value of analysis term name.
#' @param analysis_title A character value of analysis title name.
#' @param population_subset An unquoted condition for selecting the
#'   populations from dataset of population.
#' @param observation_subset An unquoted condition for selecting the
#'   populations from dataset of observation
#' @param population_label A character value of population label.
#' @param treatment_group A character value of treatment group name.
#'
#' @return A metalite object.
#'
#' @export
#'
#' @examples
#' meta_sl(
#'   dataset_population = r2rtf::r2rtf_adsl,
#'   population_term = "apat",
#'   parameter_term = "age;race",
#'   parameter_var = "AGE^AGEGR1;RACE"
#' )
meta_sl <- function(
    dataset_population,
    dataset_observation = NULL,
    population_term,
    observation_term = NULL,
    parameter_term = "age;race;gender",
    parameter_var = "AGE^AGEGR1;RACE;SEX",
    parameter_labels = NULL,
    analysis_term = "base_char",
    analysis_title = "Participant Baseline Characteristics by Treatment Group",
    population_subset = SAFFL == "Y",
    observation_subset = NULL,
    population_label = "All Participants as Treated",
    treatment_group = "TRT01A") {
  # Check input
  if (is.null(dataset_observation)) {
    dataset_observation <- dataset_population
  }
  if (is.null(observation_term)) {
    observation_term <- population_term
  }
  if (rlang::quo_is_null(rlang::enquo(observation_subset))) {
    observation_subset <- rlang::enquo(population_subset)
  }

  # Parse parameters
  parameter_terms <- unlist(strsplit(parameter_term, ";"))

  if (!length(parameter_terms) == length(unlist(strsplit(parameter_var, ";")))) {
    stop("The number of parameter labels should be the same as that of parameter terms.")
  }
  parameter_vars <- strsplit(unlist(strsplit(parameter_var, ";")), "^", fixed = TRUE)

  meta <- metalite::meta_adam(
    population = as.data.frame(dataset_population),
    observation = as.data.frame(dataset_observation)
  ) |>
    metalite::define_plan(plan = metalite::plan(
      analysis = analysis_term,
      population = population_term,
      observation = observation_term,
      parameter = parameter_term
    )) |>
    metalite::define_population(
      name = population_term,
      group = treatment_group,
      subset = !!rlang::enquo(population_subset),
      var = names(dataset_population),
      label = population_label
    ) |>
    metalite::define_observation(
      name = observation_term,
      group = treatment_group,
      subset = !!rlang::enquo(observation_subset),
      var = names(dataset_observation),
      label = ""
    )

  for (i in seq(parameter_terms)) {
    var <- parameter_vars[[i]]
    vargroup <- NULL
    if (length(parameter_vars[[i]]) > 2) {
      warning("The hat symbol (^) can separate only 2 input, a variable and its group variable.")
    } else if (length(parameter_vars[[i]]) == 2) {
      var <- parameter_vars[[i]][[1]]
      vargroup <- parameter_vars[[i]][[2]]
    }
    if (!is.null(parameter_labels)) {
      varlabel <- ifelse(!is.na(parameter_labels[i]),
        parameter_labels[i],
        attr(dataset_population[[var]], "label")
      )
    } else {
      varlabel <- attr(dataset_population[[var]], "label")
    }

    meta <- meta |>
      metalite::define_parameter(
        name = parameter_terms[[i]],
        var = var,
        vargroup = vargroup,
        label = varlabel
      )
  }

  meta <- meta |>
    metalite::define_analysis(
      name = analysis_term,
      label = "",
      title = analysis_title,
      var_name = unlist(parameter_vars)
    ) |>
    metalite::meta_build()

  meta
}
