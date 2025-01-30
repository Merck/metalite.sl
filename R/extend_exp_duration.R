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

#' Add cumulative count and summary stats for categories for exposure duration analysis
#'
#' @param outdata An `outdata` object created by [prepare_exp_duration()].
#' @param category_section_label A character value of section label.
#'  If `NULL`, the parameter label is used with "(cumulative)".
#' @param duration_category_list A list of duration category ranges.
#'   Must be real numbers and may overlap or be mutually exclusive.
#'   A list should be in the form of `list(c(low1, high1), c(low2, high2), ...)`.
#'   If `NA` is included in the range, it is treated as `-Inf` or `Inf`.
#'   The range is defined as `low <= x < high` for each.
#' @param duration_category_labels A character vector of internal labels.
#'   Labels to be displayed for the duration_category_list values.
#'   Must be the same length as duration_category_list.
#'
#' @return A list of analysis raw datasets.
#'
#' @export
#'
#' @examples
#' meta <- meta_sl_exposure_example()
#' outdata <- meta |> prepare_exp_duration()
#' outdata |>
#'   extend_exp_duration(
#'     duration_category_list = list(c(1, NA), c(7, NA), c(28, NA), c(12 * 7, NA), c(24 * 7, NA)),
#'     duration_category_labels = c(">=1 day", ">=7 days", ">=28 days", ">=12 weeks", ">=24 weeks")
#'   )
extend_exp_duration <- function(outdata,
                                category_section_label = NULL,
                                duration_category_list = NULL,
                                duration_category_labels = NULL) {
  res <- outdata
  meta <- res$meta
  analysis <- res$analysis
  population <- res$population
  parameter <- res$parameter

  # Input check
  if (!length(unlist(strsplit(parameter, ";"))) == 1) {
    stop("Only one parameter is allowed with `duration_category_list`.")
  }
  if (!is.null(duration_category_list)) {
    if (!length(duration_category_list) == length(duration_category_labels)) {
      stop("Length of `duration_category_list` and `duration_category_labels` should be the same.")
    }
    if (!is.list(duration_category_list)) {
      stop("`duration_category_list` should be a list of range vectors.")
    }
    if (!all(sapply(duration_category_list, function(x) {
      length(x) == 2
    }))) {
      stop("Each element of `duration_category_list` should be a vector of length 2 (low, high).")
    }
    if (!all(sapply(duration_category_list, function(x) {
      class(x) %in% c("numeric", "integer")
    }))) {
      stop("Each element of `duration_category_list` allows `NA`, numeric or integer.")
    }
  }

  char_n <- res$char_n[[1]]
  char_prop <- res$char_prop[[1]]
  observation <- meta$plan[meta$plan$analysis == analysis, ]$observation

  # obtain variables
  pop_var <- metalite::collect_adam_mapping(meta, population)$var
  obs_var <- metalite::collect_adam_mapping(meta, observation)$var
  par_var <- metalite::collect_adam_mapping(meta, parameter)$var
  par_var_group <- metalite::collect_adam_mapping(meta, parameter)$vargroup

  pop_group <- metalite::collect_adam_mapping(meta, population)$group
  obs_group <- metalite::collect_adam_mapping(meta, observation)$group

  pop_id <- metalite::collect_adam_mapping(meta, population)$id
  obs_id <- metalite::collect_adam_mapping(meta, observation)$id

  # variable check
  if (!res$var_type[[1]] %in% c("numeric", "integer")) {
    stop("The variable type of the parameter should be continuous to apply `extend_exp_duration`.")
  }

  # obtain data
  pop <- metalite::collect_population_record(meta, population, var = c(par_var))

  # obtain group names
  group <- unique(pop[[pop_group]])

  # count the number of subjects in each arms
  n_pop <- metalite::n_subject(id = pop[[pop_id]], group = pop[[pop_group]])
  names(n_pop) <- do.call(
    c,
    lapply(
      factor(names(n_pop), levels = levels(pop[[pop_group]])) |> as.numeric(),
      function(x) {
        paste0("n_", x)
      }
    )
  )
  n_pop$n_9999 <- sum(n_pop[1, ])
  n_pop$name <- "Participants in population"
  n_pop <- n_pop[, c(length(group) + 2, 1:(length(group) + 1))]

  # create category

  data_population <- meta$data_population

  # `var_group` is specified with numeric variable `par_var`
  if (!is.null(par_var_group) & !is.null(par_var)) {
    if (!is.factor(data_population[[par_var_group]])) {
      data_population[[par_var_group]] <- factor(data_population[[par_var_group]], levels = levels(unique(data_population[[par_var_group]])))
    }
    category_conditions <- paste0("==", "'", levels(unique(data_population[[par_var_group]])), "'")
    category_labels <- levels(unique(data_population[[par_var_group]]))
    char_stat_groups <- list()

    # calculate for each category
    for (i in seq_along(category_conditions)) {
      condition <- category_conditions[i]
      label <- category_labels[i]

      # Create subgroup
      if (!par_var_group == "TRTDURGR") {
        data_population$TRTDURGR <- data_population[[par_var_group]]
      }
      data_population$TRTDURGR <- factor(data_population[[par_var_group]], levels = label)
      # Create metadata for subgroup
      pop_subset <- metalite::collect_adam_mapping(meta, population)$subset
      pop_subset <- rlang::quo(TRTDURGR == !!label & !!pop_subset)

      meta_group <- meta_sl(
        data_population,
        dataset_observation = NULL,
        population_term = population,
        observation_term = NULL,
        parameter_term = paste0(parameter, "_group"),
        parameter_var = par_var,
        parameter_labels = metalite::collect_adam_mapping(meta, parameter)$label,
        analysis_term = paste0(analysis, "_group"),
        analysis_title = metalite::collect_adam_mapping(meta, analysis)$title,
        population_subset = !!rlang::enquo(pop_subset),
        observation_subset = NULL,
        population_label = metalite::collect_adam_mapping(meta, population)$label,
        treatment_group = metalite::collect_adam_mapping(meta, population)$group
      )

      if (nrow(metalite::collect_population_record(meta_group, population)) > 0) {
        char_stat_group <- collect_baseline(meta_group, population, paste0(names(meta$parameter), "_group"))[[2]]
        sum <- char_stat_group
        sum[names(char_n)[!names(char_n) %in% names(sum)]] <- NA
        sum <- sum[, names(char_n)]
        char_stat_groups[[label]] <- sum
        outdata$char_stat_groups <- char_stat_groups
      }
    }
  }
  # Duration category is not specified
  if (is.null(duration_category_list) & !is.null(par_var_group)) {
    count <- char_n[1:(which(is.na(char_n$name)) - 1), ]
    prop <- char_prop[1:(which(is.na(char_prop$name)) - 1), ]
    
    outdata$char_n_cum <- count |> list()
    outdata$char_prop_cum <- prop |> list()
    if (!is.null(outdata$char_stat_groups)) {
      outdata$char_stat_cums <- outdata$char_stat_groups
    }
  }
  # Duration category is specified
  if (!is.null(duration_category_list) & !is.null(par_var)) {
    data_population$TRTDURGR <- NA
    char_stat_cums <- list()
    count_cum <- data.frame()
    # calculate for each category
    for (i in seq_along(duration_category_list)) {
      condition <- duration_category_list[[i]]
      low <- ifelse(is.na(condition[1]), -Inf, condition[1])
      high <- ifelse(is.na(condition[2]), Inf, condition[2])
      if (high <= low) {
        warning("The upper limit of the range should be greater than the lower limit.")
      }
      label <- duration_category_labels[i]
      filter <- paste(low, "<=", "data_population[par_var] & data_population[par_var]", "<", high)
      data_population$TRTDURGR[eval(parse(text = filter))] <- label

      # Create subgroup
      # Create metadata for subgroup
      pop_subset <- metalite::collect_adam_mapping(meta, population)$subset
      pop_subset <- rlang::quo(TRTDURGR == !!label & !!pop_subset)

      if (is.null(category_section_label)) {
        category_section_label <- paste0(metalite::collect_adam_mapping(meta, parameter)$label, " (cumulative)")
      }

      meta_cum <- meta_sl(
        data_population,
        dataset_observation = NULL,
        population_term = population,
        observation_term = NULL,
        parameter_term = paste0(parameter, "_cum"),
        parameter_var = paste0(par_var, "^TRTDURGR"),
        parameter_labels = category_section_label,
        analysis_term = paste0(analysis, "_cum"),
        analysis_title = metalite::collect_adam_mapping(meta, analysis)$title,
        population_subset = !!rlang::enquo(pop_subset),
        observation_subset = NULL,
        population_label = metalite::collect_adam_mapping(meta, population)$label,
        treatment_group = metalite::collect_adam_mapping(meta, population)$group
      )
      if (nrow(metalite::collect_population_record(meta_cum, population)) > 0) {
        char_stat_cum <- collect_baseline(meta_cum, population, paste0(names(meta$parameter), "_cum"))[[2]]

        count <- char_stat_cum[1:(which(is.na(char_stat_cum$name)) - 1), ]
        count[names(char_n)[!names(char_n) %in% names(count)]] <- 0
        count <- count[, names(char_n)]

        sum <- char_stat_cum[(which(is.na(char_stat_cum$name)) + 1):nrow(char_stat_cum), ]
        sum[names(char_n)[!names(char_n) %in% names(sum)]] <- NA
        sum <- sum[, names(char_n)]

        count_cum <- rbind(count_cum, count)
        char_stat_cums[[label]] <- sum
      } else {
        count <- cbind("name" = label, "var_label" = category_section_label) |> data.frame()
        count[names(char_n)[!names(char_n) %in% names(count)]] <- 0
        count <- count[, names(char_n)]
        count_cum <- rbind(count_cum, count)
      }
    }
    char_prop_cum <- sapply(names(count_cum), function(x) {
      if (x %in% c(levels(group), "Total")) {
        i <- which(names(count_cum) == x)
        (as.numeric(count_cum[[i]]) / n_pop[[i]]) * 100
      } else {
        count_cum[[x]]
      }
    }) |> as.data.frame()

    outdata$char_n_cum <- count_cum |> list()
    outdata$char_prop_cum <- char_prop_cum |> list()
    outdata$char_stat_cums <- char_stat_cums
  }

  outdata$extend_call <- c(outdata$extend_call, match.call())

  return(outdata)
}
