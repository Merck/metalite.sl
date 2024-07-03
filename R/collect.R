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

#' Count number of subjects
#'
#' @param meta A metadata object created by metalite.
#' @param population A character value of population term name.
#'   The term name is used as key to link information.
#' @param parameter A character value of parameter term name.
#'   The term name is used as key to link information.
#' @param type A character value to control title name,
#'   e.g., Subjects or Records.
#' @param use_na A character value for whether to include `NA` values
#' in the table. See the `useNA` argument in [base::table()] for more details.
#' @param display_total A logical value to display total column.
#' @return A list containing number of subjects
#' @export
#'
#' @examples
#' meta <- meta_sl_example()
#' meta |> collect_baseline(
#'   population = "apat",
#'   parameter = "age"
#' )
collect_baseline <- function(
    meta,
    population,
    parameter,
    type = "Subjects",
    use_na = c("ifany", "no", "always"),
    display_total = TRUE) {
  use_na <- match.arg(use_na)

  title <- c(
    all = glue::glue("Number of {type}"),
    with_data = glue::glue("{type} with Data"),
    missing = "Missing"
  )

  if (display_total) {
    meta <- metalite::meta_add_total(meta)
  }

  # Obtain variables
  par_var <- metalite::collect_adam_mapping(meta, parameter)$var
  par_var_group <- metalite::collect_adam_mapping(meta, parameter)$vargroup
  par_var_lower <- metalite::collect_adam_mapping(meta, parameter)$var_lower

  # Obtain Data
  pop <- metalite::collect_population_record(meta, population, var = c(par_var))

  # Obtain ID
  pop_id <- metalite::collect_adam_mapping(meta, population)$id

  # Obtain Group
  pop_group <- metalite::collect_adam_mapping(meta, population)$group

  # Define analysis dataset
  uid <- pop[[pop_id]]
  id <- seq(uid)
  group <- pop[[pop_group]]
  var <- pop[[par_var]]

  class_var <- class(var)

  # Check ID duplication
  if (any(duplicated(uid[!group %in% "Total"]))) {
    warning(pop_id, " is not a unique ID")
  }

  # Obtain variable label
  label <- metalite::collect_adam_mapping(meta, parameter)$label
  if (is.null(label)) {
    label <- metalite::collect_adam_mapping(meta, parameter)$var
  }

  # standardize group variable
  stopifnot(inherits(group, c("factor", "character")))
  group <- factor(group, exclude = NULL)
  levels(group)[is.na(levels(group))] <- "Missing"

  # standardize continuous variables
  stopifnot(inherits(var, c("numeric", "integer", "factor", "character", "logical")))

  # summary of population
  all <- rep(title["all"], length(var))
  pop_all <- metalite::n_subject(id, group, par = all)

  var_n <- factor(is.na(var), c(FALSE, TRUE), title[c("with_data", "missing")])

  # Obtain Number of Subjects
  pop_n <- metalite::n_subject(id, group, par = var_n)

  # Transfer logical value
  if ("logical" %in% class_var) {
    class_var <- "character"
    var <- factor(var, c(TRUE, FALSE), c("Yes", "No"))
  }

  if (any(c("numeric", "integer") %in% class_var)) {
    # calculate summary statistics
    pop_num <- tapply(var, group, function(x) {
      value <- c(
        Mean = mean(x, na.rm = TRUE),
        SD = stats::sd(x, na.rm = TRUE),
        SE = stats::sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x))),
        Median = stats::median(x, na.rm = TRUE),
        Min = min(x, na.rm = TRUE),
        Max = max(x, na.rm = TRUE)
      )
      value <- formatC(value, format = "f", digits = 1)

      value <- c(value,
        `Q1 to Q3` = paste0(
          stats::quantile(x, probs = 0.25, na.rm = TRUE, names = FALSE), " to ",
          stats::quantile(x, probs = 0.75, na.rm = TRUE, names = FALSE)
        ),
        Range = paste0(min(x, na.rm = TRUE), " to ", max(x, na.rm = TRUE))
      )

      value
    })
    pop_num <- t(do.call(rbind, pop_num))
    pop_num <- data.frame(
      name = row.names(pop_num),
      pop_num
    )
    # combine results
    names(pop_num) <- names(pop_n)
    row.names(pop_num) <- NULL
    # add percentage
    pop_prop <- pop_num
    for (i in 2:ncol(pop_prop)) {
      pop_prop[, i] <- NA
    }
  }

  # standardize categorical variables
  if (any(c("factor", "character") %in% class_var)) {
    var <- factor(var, exclude = NULL)

    if (all(is.na(var))) {
      levels(var) <- c(levels(var), title["missing"])
    } else {
      levels(var)[is.na(levels(var))] <- title["missing"]
    }

    # Obtain Number of Subjects
    pop_num <- metalite::n_subject(id, group, par = var)

    pop_prop <- pop_num
    for (i in seq(names(pop_prop))) {
      if ("integer" %in% class(pop_prop[[i]])) {
        pct <- pop_prop[[i]] / pop_all[[i]] * 100
        pop_prop[[i]] <- pct
      }
    }
  }

  # variable group
  if (!is.null(par_var_group)) {
    vargroup <- pop[[par_var_group]]
    stopifnot(inherits(vargroup, c("factor", "character")))
    vargroup <- factor(vargroup, exclude = NULL)

    if (all(is.na(vargroup))) {
      levels(vargroup) <- c(levels(vargroup), title["missing"])
    } else {
      levels(vargroup)[is.na(levels(vargroup))] <- title["missing"]
    }

    # Obtain Number of Subjects
    pop_num_group <- metalite::n_subject(id, group, par = vargroup)

    pop_prop_group <- pop_num_group
    for (i in seq(names(pop_prop_group))) {
      if ("integer" %in% class(pop_prop_group[[i]])) {
        pct <- pop_prop_group[[i]] / pop_all[[i]] * 100
        pop_prop_group[[i]] <- pct
      }
    }

    pop_num <- rbind(pop_num_group, pop_num)
    pop_prop <- rbind(pop_prop_group, pop_prop)
  }

  # variable lower level
  if (!is.null(par_var_lower)) {

    # Obtain number of subjects
    pop_num_lower <- apply(pop_num, 1, function (x) {
      pop_lower <- pop[pop[[par_var]] == x[["name"]] & !is.na(pop[[par_var_lower]]), ]
      id_lower <- seq(pop_lower[[pop_id]])
      group_lower <- pop_lower[[pop_group]]
      varlower <- pop_lower[[par_var_lower]]
      stopifnot(inherits(varlower, c("factor", "character")))
      varlower <- factor(varlower, exclude = NULL)
      
      if (length(varlower) > 0) {
        lower <- metalite::n_subject(id_lower, group_lower, par = varlower)
        max_length <- sapply(pop_num, function(x) max(nchar(x)))
        for (i in 2:length(max_length)) {
          lower[[i]] <- formatC(lower[[i]], width = max_length[[i]])
        }

        lower$name <- paste("   ", lower$name)
        rbind(x, lower)
      } else {
        as.data.frame(t(x))
      }
    })
    pop_num <- do.call(rbind, pop_num_lower)
    
    # Obtain proportion
    pop_prop_lower <- apply(pop_prop, 1, function (x) {
      pop_lower <- pop[pop[[par_var]] == x[["name"]] & !is.na(pop[[par_var_lower]]), ]
      id_lower <- seq(pop_lower[[pop_id]])
      group_lower <- pop_lower[[pop_group]]
      varlower <- pop_lower[[par_var_lower]]
      stopifnot(inherits(varlower, c("factor", "character")))
      varlower <- factor(varlower, exclude = NULL)
      
      if (length(varlower) > 0) {
        lower <- metalite::n_subject(id_lower, group_lower, par = varlower)
        for (i in seq(names(lower))) {
          if ("integer" %in% class(lower[[i]])) {
            pct <- lower[[i]] / pop_all[[i]] * 100
            lower[[i]] <- pct
          }
        }
        lower$name <- paste("   ", lower$name)
        rbind(x, lower)
      } else {
        as.data.frame(t(x))
      }
    })
    pop_prop <- do.call(rbind, pop_prop_lower)
    
  }
  
  pop_n["var_label"] <- label
  pop_num["var_label"] <- label
  pop_prop["var_label"] <- label

  list(n = pop_n, stat = pop_num, pop = pop_prop, var_type = class_var)
}
